#!/usr/bin/env bash
set -u

NIGHT_TEMP=3500

have() { command -v "$1" >/dev/null 2>&1; }

toggle() {
  if ! have gammastep; then
    exit 0
  fi

  if pgrep -x gammastep >/dev/null 2>&1; then
    pkill -x gammastep 2>/dev/null || true
  else
    gammastep -O "$NIGHT_TEMP" >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi
}

status() {
  local icon tooltip class

  icon="󰖨 "
  tooltip="Night Mode Off"
  class="off"

  if have gammastep && pgrep -x gammastep >/dev/null 2>&1; then
    icon=" "
    tooltip="Night Mode On"
    class="on"
  fi

  # Properly escape JSON key-values using printf
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
}

case "${1:-status}" in
toggle) toggle ;;
status) status ;;
*) exit 1 ;;
esac
