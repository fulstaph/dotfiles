#!/bin/bash

# Get the current volume level
VOLUME=$(amixer get Master | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')

# Get the mute status
MUTE=$(amixer get Master | grep -oP '\[on\]|\[off\]' | head -1 | tr -d '[]')

if [ "$MUTE" = "[off]" ]; then
    echo " 0%"
else
    echo " $VOLUME"
fi
