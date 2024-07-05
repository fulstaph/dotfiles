#!/bin/sh

setxkbmap -option 'caps:ctrl_modifier'

xrandr --output DP-2 --primary --mode 3840x2160 --rate 144 --scale 0.8x0.8 --output HDMI-0 --mode 3840x2160 --scale 0.8x0.8 --left-of DP-2

# Set Wallpaper
feh --bg-scale ~/dotfiles/wallpaper/3840x2160.jpg

nm-applet & # Network Manager applet
picom & # Compositor for transparency
