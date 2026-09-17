#!/usr/bin/env bash
set -u

INTERVAL_SECONDS="${INTERVAL_SECONDS:-30}"
WAKE_GAP_SECONDS="${WAKE_GAP_SECONDS:-90}"
POST_WAKE_DELAY_SECONDS="${POST_WAKE_DELAY_SECONDS:-3}"
LOG_FILE="${LOG_FILE:-$HOME/Library/Logs/sketchybar-wake-watchdog.log}"
LOCK_DIR="${TMPDIR:-/tmp}/sketchybar-wake-watchdog.lock"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Ins)" "$*" >> "$LOG_FILE"
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

brew_cmd() {
  if cmd_exists brew; then
    command -v brew
  elif [ -x /opt/homebrew/bin/brew ]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    printf '%s\n' /usr/local/bin/brew
  else
    return 1
  fi
}

query_bar() {
  if ! cmd_exists sketchybar; then
    log "sketchybar command missing"
    return 1
  fi

  if cmd_exists timeout; then
    timeout 5 sketchybar --query bar 2>/dev/null
  else
    sketchybar --query bar 2>/dev/null
  fi
}

restart_sketchybar() {
  local brew_bin
  if ! brew_bin="$(brew_cmd)"; then
    log "brew missing; cannot restart sketchybar service"
    return 1
  fi

  log "restarting sketchybar"
  "$brew_bin" services restart sketchybar >> "$LOG_FILE" 2>&1
}

check_once() {
  local output
  output="$(query_bar || true)"

  if [ -z "$output" ]; then
    log "empty sketchybar query; stale daemon/window suspected"
    restart_sketchybar
    return $?
  fi

  log "sketchybar healthy (${#output} bytes)"
  return 0
}

acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT
    return 0
  fi
  log "another watchdog instance already running"
  return 1
}

run_daemon() {
  acquire_lock || exit 0
  log "watchdog started interval=${INTERVAL_SECONDS}s wake_gap=${WAKE_GAP_SECONDS}s"

  local last_now now gap
  last_now="$(date +%s)"

  check_once || true

  while true; do
    sleep "$INTERVAL_SECONDS"
    now="$(date +%s)"
    gap=$((now - last_now))
    last_now="$now"

    if [ "$gap" -ge "$WAKE_GAP_SECONDS" ]; then
      log "wake/resume candidate detected gap=${gap}s; waiting ${POST_WAKE_DELAY_SECONDS}s"
      sleep "$POST_WAKE_DELAY_SECONDS"
    fi

    check_once || true
  done
}

case "${1:---daemon}" in
  --check-once)
    check_once
    ;;
  --daemon)
    run_daemon
    ;;
  *)
    echo "usage: $0 [--daemon|--check-once]" >&2
    exit 2
    ;;
esac
