#!/usr/bin/env bash
set -u

label="${1:-manual}"
out_dir="$HOME/Desktop/menu-sketchybar-debug"
mkdir -p "$out_dir"
out="$out_dir/$(date +%Y%m%d-%H%M%S)-$label.txt"

{
	echo "# menu/sketchybar debug capture"
	echo "timestamp=$(date -Ins)"
	echo "label=$label"
	echo

	echo "## macOS"
	sw_vers 2>&1
	uname -a 2>&1
	echo

	echo "## displays"
	system_profiler SPDisplaysDataType 2>&1 | sed -n '1,220p'
	echo

	echo "## menu/dock prefs"
	echo "NSGlobalDomain _HIHideMenuBar:"
	defaults read NSGlobalDomain _HIHideMenuBar 2>&1 || true
	echo "NSGlobalDomain AppleMenuBarVisibleInFullscreen:"
	defaults read NSGlobalDomain AppleMenuBarVisibleInFullscreen 2>&1 || true
	echo "ControlCenter AutoHideMenuBarOption:"
	defaults read com.apple.controlcenter AutoHideMenuBarOption 2>&1 || true
	echo "Dock autohide:"
	defaults read com.apple.dock autohide 2>&1 || true
	echo

	echo "## processes"
	pgrep -fl 'SketchyBar|sketchybar|SystemUIServer|Dock|WindowServer|AeroSpace|aerospace' 2>&1 || true
	echo

	echo "## ps sketchybar/plugins"
	ps -axo pid,ppid,etime,%cpu,%mem,command 2>&1 | grep -E 'sketchybar|\.config/sketchybar/plugins|SystemUIServer|WindowServer|Dock|AeroSpace|aerospace' | grep -v grep || true
	echo

	echo "## brew services"
	brew services list 2>&1 | grep -E 'sketchybar|aerospace|yabai|skhd' || true
	echo

	echo "## launchctl sketchybar"
	launchctl print "gui/$(id -u)/homebrew.mxcl.sketchybar" 2>&1 | sed -n '1,220p' || true
	echo

	echo "## sketchybar query bar"
	if command -v sketchybar >/dev/null 2>&1; then
		timeout 5 sketchybar --query bar 2>&1 || true
	else
		echo "sketchybar not in PATH"
	fi
	echo

	echo "## sketchybar query items"
	if command -v sketchybar >/dev/null 2>&1; then
		for item in aerospace chevron front_app clock volume battery disk net mem cpu space.1 space.2 space.3 space.4 space.5 space.6 space.7; do
			echo "### $item"
			timeout 3 sketchybar --query "$item" 2>&1 | sed -n '1,120p' || true
		done
	fi
	echo

	echo "## aerospace state"
	if command -v aerospace >/dev/null 2>&1; then
		echo "### monitors"
		aerospace list-monitors --json 2>&1 || true
		echo "### workspaces"
		aerospace list-workspaces --all --json 2>&1 || true
		echo "### focused window"
		aerospace list-windows --focused --json 2>&1 || true
	else
		echo "aerospace not in PATH"
	fi
	echo

	echo "## recent logs: SystemUIServer/sketchybar/Dock/WindowServer/AeroSpace"
	log show --last 10m --style compact --predicate 'process == "SystemUIServer" OR process CONTAINS[c] "sketchybar" OR process == "Dock" OR process == "WindowServer" OR process CONTAINS[c] "AeroSpace"' 2>&1 | tail -300 || true
} >"$out"

echo "$out"
