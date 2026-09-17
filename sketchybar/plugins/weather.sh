#!/bin/bash

WEATHER=$(curl -sL "wttr.in/Kumbakonam?format=%c%t" 2>/dev/null | sed 's/+//g')

if [ -z "$WEATHER" ] || echo "$WEATHER" | grep -q "Unknown"; then
  sketchybar --set "$NAME" label="--"
else
  sketchybar --set "$NAME" label="$WEATHER"
fi
