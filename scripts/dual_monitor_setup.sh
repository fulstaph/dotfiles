# set my samsung monitor to the right of thinkvision monitor
# both have 4k resolution
# set 125% scaling factor
# set refresh rate of samsung monitor to 144
xrandr --output DP-2 --primary --mode 3840x2160 --rate 144 --scale 0.8x0.8 --output HDMI-0 --mode 3840x2160 --scale 0.8x0.8 --left-of DP-2

