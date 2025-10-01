#!/usr/bin/env bash
iatest=$(expr index "$-" i)

# Set Color Scheme for TTY
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P015161e" # black
    echo -en "\e]P1f7768e" # red
    echo -en "\e]P29ece6a" # green
    echo -en "\e]P3e0af68" # yellow
    echo -en "\e]P47aa2f7" # blue
    echo -en "\e]P5bb9af7" # magenta
    echo -en "\e]P67dcfff" # cyan
    echo -en "\e]P7a9b1d6" # white
    echo -en "\e]P8414868" # bright black
    echo -en "\e]P9f7768e" # bright red
    echo -en "\e]PA9ece6a" # bright green
    echo -en "\e]PBe0af68" # bright yellow
    echo -en "\e]PC7aa2f7" # bright blue
    echo -en "\e]PDbb9af7" # bright magenta
    echo -en "\e]PE7dcfff" # bright Cyan
    echo -en "\e]PFc0caf5" # bright White
    clear                  # clear artifacts
fi

#######################################################
# SOURCED ALIAS'S AND SCRIPTS 
#######################################################
# FastFetch
if [ -f /usr/bin/fastfetch ]; then
    # disable fastfetch for vscode integrated terminal	
    [[ ! "$TERM_PROGRAM" == "vscode" ]] && fastfetch
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Git Prompt
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    . /usr/share/git/completion/git-prompt.sh
fi

#######################################################
# EXPORTS
#######################################################
# Disable the bell
if [[ $iatest -gt 0 ]]; then bind 'set bell-style visible'; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Allow Ctrl-S for history navigation (with Ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind 'set completion-ignore-case on'; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind 'set show-all-if-ambiguous on'; fi
if [[ $iatest -gt 0 ]]; then bind 'TAB:menu-complete'; fi
if [[ $iatest -gt 0 ]]; then bind '"\e[Z":menu-complete-backward'; fi

# Set the default editor
export EDITOR=micro
export VISUAL=micro

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Edit this .bashrc file
alias ebrc='micro ~/.bashrc'

# Alias to show the date
alias now='date "+%d-%m-%Y %A %T %Z"'

# Alias to search through AUR
alias yayf='yay -Slq | fzf --multi --preview "yay -Sii {1}" --preview-window=down:75% | xargs -ro yay -S'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'

alias ps='ps auxf'
alias ping='ping -c 5'
alias less='less -R'
alias cat='bat'

alias cls='clear'

# Alias grep to rg for ripgrep
alias grep='rg'

# Change directory aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Alias's for multiple directory listing commands
alias la='ls -Alh'                # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -ltcrh'              # sort by change time
alias lu='ls -lturh'              # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='ls -Fls'                # long listing format
alias labc='ls -lap'              # alphabetical sort
alias lf='ls -l | egrep -v "^d'  # files only
alias ldir='ls -l | egrep "^d"'   # directories only
alias lla='ls -Al'                # List and Hidden Files
alias las='ls -A'                 # Hidden Files
alias lls='ls -l'                 # List

# Search command line history
alias h='history | grep'

# Search files in the current folder
alias f='find . | grep'

# Search running processes
alias p='ps aux | grep'

# Show open ports
alias openports='netstat -nape --inet'

# Alias's to show disk space and space used in a folder
alias treed='\tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

# SHA1
alias sha1='openssl sha1'

#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
            *.tar) tar xvf $archive ;;
            *.tar.bz2) tar xvjf $archive ;;
            *.tbz2) tar xvjf $archive ;;
            *.tar.gz) tar xvzf $archive ;;
            *.tgz) tar xvzf $archive ;;
            *.zip) unzip $archive ;;
            *.7z) 7z x $archive ;;
            *.rar) rar x $archive ;;
            *.Z) uncompress $archive ;;
            *.bz2) bunzip2 $archive ;;
            *.gz) gunzip $archive ;;
            *) echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Automatically do an ls after each cd, z, or zoxide
cd() {
    if [ -n "$1" ]; then
        builtin cd "$@" && ls
    else
        builtin cd ~ && ls
    fi
}

z() {
    if [ -n "$1" ]; then
        __zoxide_z "$@" && ls
    else
        __zoxide_z ~ && ls
    fi
}
alias zi='__zoxide_zi'

# IP address lookup
alias whatismyip='whatsmyip'
function whatsmyip () {
    # Internal IP Lookup
    echo -ne "\033[33mInternal IP:\033[0m\n"
    ifconfig | \grep "inet " | awk -F'[: ]+' '{ print $NF }'
    # External IP Lookup
    echo -ne "\033[33mExternal IP:\033[0m\n"
    curl -4 ifconfig.me
    echo -e "\n"
}

#######################################################
# GIT
#######################################################

alias status='git status && git diff --shortstat'
alias switch='git switch'
alias checkout='git checkout'
alias commit='git commit -v -m'
alias pull='git pull --ff-only'
alias push='git push -v'
alias merge='git merge -v --no-ff'
alias fetch='git fetch origin --tags'
alias gitk='gitk --all --branches'
alias dd='git diff --word-diff=color'
alias su='git submodule update --recursive'

alias amend='git commit --amend --no-edit -v'
alias wip='git add -A && git commit -m "___WIP___"'
alias rewip='git reset --soft HEAD^'

alias hide='git stash save temp_backup --include-untracked'
alias rehide='git stash pop stash@{0}'

alias unstage='git reset HEAD --'
alias cleanup='git reset --hard'

alias initempty='git init && git commit -m “root” --allow-empty'
alias please='git push -v --force-with-lease'

alias exclude='!f() { nano .git/info/exclude; }; f'
alias untrack='git update-index --assume-unchanged --verbose'
alias track='git update-index --no-assume-unchanged --verbose'

alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
alias gittree="git log --graph --abbrev-commit --decorate --all --format=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)\""

alias tree='treef'
function treef () {
    if ( git rev-parse --is-inside-work-tree >/dev/null 2>&1 ); then
        gittree
    else 
        \tree -CAhF --dirsfirst
    fi
}
#######################################################
# Set the zoxide, fzf and command prompt
#######################################################

# Check if the shell is interactive
if [[ $- == *i* ]]; then
    # Bind Ctrl+f to insert 'zi' followed by a newline
    bind '"\C-f":"zi\n"'
fi

# Extend PATH 
export PATH=$PATH:"$HOME/.local/bin:$HOME/.fzf/bin"

# Prompt
_green="\[\e[1;32m\]"
_reset="\[\e[0m\]"
_blue="\[\e[1;34m\]"
_yelow="\[\e[1;33m\]"
_red="\[\e[1;31m\]"
PS1="$_blue[$_green\u$_blue@$_green\h$_blue] \t [$_yelow\w$_blue]$_red \$(__git_ps1 '(%s)')$_reset\n\$ "

eval "$(zoxide init bash --no-cmd)"
eval "$(fzf --bash)"
