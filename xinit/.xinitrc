#!/bin/sh

setxkbmap -option 'caps:ctrl_modifier'
setxkbmap -layout "au,ru"
setxkbmap -option grp:alt_shift_toggle au,ru

# Multi monitor setup on desktop pc
if [ "$(hostname)" = "homepc" ]; then
    xrandr --output DP-2 --primary --mode 3840x2160 --rate 144 --scale 0.8x0.8 --output HDMI-0 --mode 3840x2160 --scale 0.8x0.8 --left-of DP-2
fi

# Fix tearing on the laptop
if [ "$(hostname)" = "thinkpad" ]; then
    xrandr --output eDP --set TearFree on
fi

# Set Wallpaper
feh --bg-scale ~/dotfiles/wallpaper/3840x2160.jpg

nm-applet & # Network Manager applet
picom & # Compositor for transparency
pwvucontrol & # Audio manager app

