#!/bin/bash
# firt, you have to install this formula from brew (https://github.com/narugit/smctemp)
TEMP=$(/opt/homebrew/bin/smctemp -c)

# if [ $? -ne 0 ]; then
# 	echo "Something has gone wrong."
# 	exit 1
# fi

sketchybar --set temp label=" ${TEMP}°C"
