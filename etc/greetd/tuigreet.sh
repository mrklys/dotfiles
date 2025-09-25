#!/bin/sh

# Set Color Scheme for TTY
echo -en "\e]P015161e" # black
echo -en "\e]P1f7768e" # red
echo -en "\e]P29ece6a" # green
echo -en "\e]P47aa2f7" # blue
echo -en "\e]P67dcfff" # cyan
clear

exec tuigreet --remember --remember-session --sessions /etc/tuigreet/sessions --width 100 --greeting "BTW, I use Arch." --time --theme 'border=cyan;text=cyan;prompt=green;time=red;action=blue;button=cyan;container=black;input=red'
