#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/.config/sketchybar/scripts/sketchybar-wake-watchdog.sh"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}
pass() { echo "PASS: $*"; }

run_case() {
	local name="$1"
	local query_output="$2"
	local expected_restarts="$3"

	local tmp
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' RETURN

	mkdir -p "$tmp/bin"
	cat >"$tmp/bin/sketchybar" <<EOF
#!/usr/bin/env bash
if [ "\${1:-}" = "--query" ] && [ "\${2:-}" = "bar" ]; then
  printf '%s' '$query_output'
  exit 0
fi
exit 0
EOF
	chmod +x "$tmp/bin/sketchybar"

	cat >"$tmp/bin/brew" <<EOF
#!/usr/bin/env bash
echo "brew \$*" >> "$tmp/restarts.log"
exit 0
EOF
	chmod +x "$tmp/bin/brew"

	PATH="$tmp/bin:$PATH" LOG_FILE="$tmp/watchdog.log" "$SCRIPT" --check-once >/dev/null

	local got=0
	if [ -f "$tmp/restarts.log" ]; then
		got="$(grep -c 'brew services restart sketchybar' "$tmp/restarts.log" || true)"
	fi

	if [ "$got" != "$expected_restarts" ]; then
		echo "--- watchdog log ---" >&2
		cat "$tmp/watchdog.log" >&2 || true
		fail "$name expected $expected_restarts restarts, got $got"
	fi

	pass "$name"
}

[ -x "$SCRIPT" ] || fail "watchdog script missing or not executable: $SCRIPT"

run_case "valid query does not restart" '{"position":"top"}' 0
run_case "empty query restarts sketchybar" '' 1
