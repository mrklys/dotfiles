#!/bin/bash

# ---------------------------------------------------------------------- CONFIG
# iso=$(curl -4 ifconfig.io/country_code)
iso="UA"
CPU_CORES=$(nproc)
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
INSTALL_YAY=1
INSTALL_BASH=1
INSTALL_DWM=1

#------------------------------------------------------------------------------

# Redirect stdout and stderr to archinstall.log and still output to console
exec > >(tee -i archinstall.log)
exec 2>&1

# Set Font
setfont ter-v18b

echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------

"
# Background Checks
if [ ! -f /usr/bin/pacstrap ]; then
    echo "This script must be run from an Arch Linux ISO environment.\n"
    exit 1
fi
if [[ "$(id -u)" != "0" ]]; then
    echo -ne "ERROR! This script must be run under the 'root' user!\n"
    exit 0
fi
if [[ ! -e /etc/arch-release ]]; then
    echo -ne "ERROR! This script must be run in Arch Linux!\n"
    exit 0
fi

# Gather username and password to be used for installation.
while true
do
        read -r -p "Please enter username: " username
        if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
        then
                break
        fi
        echo "Incorrect username."
done
export USERNAME=$username
while true
do
    read -rs -p "Please enter password: " PASSWORD1
    echo -ne "\n"
    read -rs -p "Please re-enter password: " PASSWORD2
    echo -ne "\n"
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        break
    else
        echo -ne "ERROR! Passwords do not match. \n"
    fi
done
export PASSWORD=$PASSWORD1

# Loop through user input until the user gives a valid hostname, but allow the user to force save
while true
do
        read -r -p "Please name your machine: " hostname
        # hostname regex (!!couldn't find spec for computer name!!)
        if [[ "${hostname,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
        then
                break
        fi
        # if validation fails allow the user to force saving of the hostname
        read -r -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force
        if [[ "${force,,}" = "y" ]]
        then
                break
        fi
done
export HOSTNAME=$hostname

export KEYMAP="us"
time_zone="$(curl --fail https://ipapi.co/timezone)"
export TIMEZONE=$time_zone

# Disk selection for drive to be used with installation
echo -ne "
------------------------------------------------------------------------
    THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
    Please make sure you know what you are doing because
    after formatting your disk there is no way to get data back
    *****BACKUP YOUR DATA BEFORE CONTINUING*****
------------------------------------------------------------------------

"
lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'

read -r -p "Select the disk to install on:: " disk

export DISK=$disk
export MOUNT_OPTIONS="noatime,compress=zstd,ssd,commit=120"

echo -ne "
-------------------------------------------------------------------------
                    Installing PreRequisites
-------------------------------------------------------------------------
"
timedatectl set-ntp true
pacman -Sy
pacman -S --noconfirm archlinux-keyring # update keyrings to latest to prevent packages failing to install
pacman -S --noconfirm --needed pacman-contrib reflector rsync gptfdisk glibc

echo -ne "
-------------------------------------------------------------------------
            Setting up $iso mirrors for faster downloads
-------------------------------------------------------------------------
"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector -a 48 -c "$iso" --score 5 -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
if [[ $(grep -c "Server =" /etc/pacman.d/mirrorlist) -lt 5 ]]; then # check if there are less than 5 mirrors
    cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
fi

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

echo -ne "
-------------------------------------------------------------------------
                        Formatting Disk
-------------------------------------------------------------------------
"
# TODO: add last chinese warning

if [ ! -d "/mnt" ]; then
    mkdir /mnt
fi

# Make sure everything is unmounted before we start
umount -A --recursive /mnt 

# Disk prep
sgdisk -Z "${DISK}" # zap all on disk
sgdisk -a 2048 -o "${DISK}" # new gpt disk 2048 alignment

# Create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' "${DISK}"  # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+2GiB --typecode=2:ef00 --change-name=2:'EFIBOOT' "${DISK}" # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' "${DISK}"       # partition 3 (root)

if [[ ! -d "/sys/firmware/efi" ]]; then # Checking for bios system
    sgdisk -A 1:set:2 "${DISK}"
fi

# Reread partition table to ensure it is correct
partprobe "${DISK}" 

echo -ne "
-------------------------------------------------------------------------
                        Creating Filesystems
-------------------------------------------------------------------------
"
if [[ "${DISK}" =~ "nvme" ]]; then
    partition2=${DISK}p2
    partition3=${DISK}p3
else
    partition2=${DISK}2
    partition3=${DISK}3
fi

mkfs.fat -F32 -n "EFIBOOT" "${partition2}"
mkfs.ext4 "${partition3}"

mount -t ext4 "${partition3}" /mnt
sync

if ! mountpoint -q /mnt; then
    echo "ERROR! Failed to mount ${partition3} to /mnt after multiple attempts."
    exit 1
fi

mkdir -p /mnt/boot
BOOT_UUID=$(blkid -s UUID -o value "${partition2}")
mount -U "${BOOT_UUID}" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue\n"
    exit 0
fi

echo -ne "
-------------------------------------------------------------------------
                    Arch Install on Main Drive
-------------------------------------------------------------------------
"
pacstrap /mnt base base-devel linux linux-firmware --noconfirm --needed

cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf

genfstab -U /mnt >> /mnt/etc/fstab
echo "
  Generated /etc/fstab:
"
cat /mnt/etc/fstab

echo -ne "
-------------------------------------------------------------------------
                Checking for low memory systems <8G
-------------------------------------------------------------------------
"
if [[  $TOTAL_MEM -lt 8000000 ]]; then
    # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir -p /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
    if findmnt -n -o FSTYPE /mnt | grep -q btrfs; then
        chattr +C /mnt/opt/swap # apply NOCOW, btrfs needs that.
    fi
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile # set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    # The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the system itself.
    echo "/opt/swap/swapfile    none    swap    sw    0    0" >> /mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi

echo -ne "
-------------------------------------------------------------------------
                    Boot from installed system
-------------------------------------------------------------------------
"
arch-chroot /mnt /bin/bash -c "KEYMAP='${KEYMAP}' /bin/bash" << EOF

echo -ne "
-------------------------------------------------------------------------
                    Install essential packages
-------------------------------------------------------------------------
"
pacman -S --noconfirm --needed pacman-contrib reflector rsync ntp       
pacman -S --noconfirm --needed grub efibootmgr
pacman -S --noconfirm --needed terminus-font micro mc
pacman -S --noconfirm --needed git gcc make curl wget

echo -ne "
-------------------------------------------------------------------------
                    GRUB Bootloader Install
-------------------------------------------------------------------------
"
if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
else
    grub-install --boot-directory=/boot "${DISK}"
fi

# Set kernel parameter
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 splash"/' /etc/default/grub

echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg

echo -ne "
-------------------------------------------------------------------------
                            Network Setup
-------------------------------------------------------------------------
"
pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager

echo -ne "
-------------------------------------------------------------------------
            Changing the makeflags for "$CPU_CORES" cores. 
            As well as changing the compression settings.
-------------------------------------------------------------------------
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -gt 8000000 ]]; then
    sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$CPU_CORES\"/g" /etc/makepkg.conf
    sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $CPU_CORES -z -)/g" /etc/makepkg.conf
fi

echo -ne "
-------------------------------------------------------------------------
                Setup Language to US and set locale
-------------------------------------------------------------------------
"
# Set locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

# Set the time zone:
timedatectl --no-ask-password set-timezone ${TIMEZONE}
timedatectl --no-ask-password set-ntp 1
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Set keymaps
echo -e "KEYMAP=${KEYMAP}\nXKBLAYOUT=${KEYMAP}\nFONT=ter-v18b" > /etc/vconsole.conf
echo "Keymap set to: ${KEYMAP}"

# Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Set colors and enable the easter egg
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf

# Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

echo -ne "
-------------------------------------------------------------------------
                        Installing Microcode
-------------------------------------------------------------------------
"
# Determine processor type and install microcode
if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
else
    echo "Unable to determine CPU vendor. Skipping microcode installation."
fi

echo -ne "
-------------------------------------------------------------------------
                    Installing Graphics Drivers
-------------------------------------------------------------------------
"
# Graphics Drivers find and install
gpu_type=$(lspci | grep -E "VGA|3D|Display")

if echo "${gpu_type}" | grep -E "NVIDIA|GeForce"; then
    echo "Installing NVIDIA drivers: nvidia"
    pacman -S --noconfirm --needed nvidia ### open-nvidia for 20xx series and newer ?
elif echo "${gpu_type}" | grep 'VGA' | grep -E "Radeon|AMD"; then
    echo "Installing AMD drivers: xf86-video-amdgpu"
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif echo "${gpu_type}" | grep -E "Integrated Graphics Controller"; then
    echo "Installing Intel drivers:"
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif echo "${gpu_type}" | grep -E "Intel Corporation UHD"; then
    echo "Installing Intel UHD drivers:"
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

echo -ne "
-------------------------------------------------------------------------
                            Adding User
-------------------------------------------------------------------------
"
# Create user
groupadd libvirt
useradd -m -G wheel,audio,video,kvm,libvirt -s /bin/bash $USERNAME
echo "$USERNAME created, home directory created, added to wheel,audio,video,kvm,libvirt groups, default shell set to /bin/bash"

# Set the user password
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME password set"

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Create the hostname file
echo $HOSTNAME > /etc/hostname
echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable NetworkManager.service
echo "NetworkManager enabled"
systemctl enable reflector.timer
echo "Reflector enabled"

if [[ $INSTALL_BASH == 1 ]]; then
echo -ne "
-------------------------------------------------------------------------
                        Bash & dotfiles install
-------------------------------------------------------------------------
"
    pacman -S --noconfirm --needed bash bash-completion zoxide fzf trash-cli tar bat tree unzip less ripgrep
    pacman -S --noconfirm --needed tldr fastfetch progress cmatrix
    pacman -S --noconfirm --needed htop btop

    # Ensure the target directory exists
    [ ! -d "/home/$USERNAME/.local/share" ] && mkdir -p "/home/$USERNAME/.local/share"
    # Clone dotfiles repo
    ( cd /home/$USERNAME/.local/share && git clone -b develop --single-branch https://github.com/mrklys/dotfiles.git )
    # Link config files
    ( cd /home/$USERNAME/.local/share/dotfiles && source ./link-configs.sh )
    # Set user as owner
    ( cd /home/$USERNAME && chown -R $USERNAME:$USERNAME .*)
fi

if [[ $INSTALL_DWM == 1 ]]; then
echo -ne "
-------------------------------------------------------------------------
                            DWM install
-------------------------------------------------------------------------
"
    echo "Install Login Manager: greetd"
    pacman -S --noconfirm --needed greetd greetd-tuigreet
    
    # Ensure the target directory exists
    [ ! -d "/etc/greetd" ] && mkdir -p "/etc/greetd"
    [ ! -d "/etc/tuigreet/sessions" ] && mkdir -p "/etc/tuigreet/sessions"
    [ ! -d "/etc/tuigreet/launchers" ] && mkdir -p "/etc/tuigreet/launchers"
    
    cp /home/$USERNAME/.local/share/dotfiles/etc/greetd/config.toml /etc/greetd/config.toml
    cp /home/$USERNAME/.local/share/dotfiles/etc/greetd/tuigreet.sh /etc/greetd/tuigreet.sh
    cp /home/$USERNAME/.local/share/dotfiles/etc/tuigreet/sessions/dwm.desktop /etc/tuigreet/sessions/dwm.desktop
    cp /home/$USERNAME/.local/share/dotfiles/etc/tuigreet/launchers/dwm.sh /etc/tuigreet/launchers/dwm.sh

    chmod +x /etc/greetd/tuigreet.sh
    chmod +x /etc/tuigreet/launchers/dwm.sh

    systemctl enable greetd.service
    echo "greetd enabled"

    echo "Install X.Org packages"
    pacman -S --noconfirm --needed xorg-xinit xorg-server xorg-xrandr
    pacman -S --noconfirm --needed base-devel git unzip libx11 libxinerama libxft imlib2 xorg-xprop picom dunst feh mate-polkit xclip
    pacman -S --noconfirm --needed alsa-utils pipewire pavucontrol
    pacman -S --noconfirm --needed fontconfig ttf-meslo-nerd
    
    # Soft
    # pacman -S --noconfirm --needed chromium lite-xl
    
    # Ensure the target directory exists
    [ ! -d "/home/$USERNAME/.local/share/de" ] && mkdir -p "/home/$USERNAME/.local/share/de"

    echo "Compile and install Desktop Environment"
    cd /home/$USERNAME/.local/share/de
    git clone -b develop --single-branch https://github.com/mrklys/dwm.git
    git clone https://github.com/mrklys/slstatus.git
    git clone https://github.com/mrklys/dmenu.git
    git clone -b develop --single-branch https://github.com/mrklys/st.git

    ( cd dwm && make clean install )
    ( cd slstatus && make clean install )
    ( cd dmenu && make clean install )
    ( cd st && make clean install )

    # workaround for .xinitrc wrong dir
    mv /home/.xinitrc /home/$USERNAME/.xinitrc

    # Set user as owner
    ( cd /home/$USERNAME && chown -R $USERNAME:$USERNAME .*)

    systemctl enable dbus.service
fi

echo -ne "
-------------------------------------------------------------------------
                    Installation Finished
-------------------------------------------------------------------------
"
EOF

# Copy installation log file
cp archinstall.log /mnt/home/$USERNAME/archinstall.log
