#!/usr/bin/env bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# shellcheck disable=SC1090
source "$CONFIG_DIR/plugins/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
	__icon_map "$INFO"
	# icon_result is set by __icon_map.
	# shellcheck disable=SC2154
	sketchybar --set "$NAME" label="$INFO" icon="$icon_result" icon.font="sketchybar-app-font:Regular:16.0"
fi
