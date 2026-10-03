#!/usr/bin/env bash

video=false
swayidle_pid=""

get_swayidle_pid() {
  swayidle_pid=$(pgrep -x swayidle | head -1)
}

kill_swayidle() {
  if [[ -n "$swayidle_pid" ]]; then
    kill "$swayidle_pid" 2>/dev/null || true
    swayidle_pid=""
  fi
}

start_swayidle() {
  swayidle -w \
    timeout 300 'swaymsg exec hyprlock' \
    timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
    before-sleep 'swaymsg exec hyprlock' &
  swayidle_pid=$!
}

while true; do
  if [[ "$(playerctl status 2>/dev/null)" == "Playing" ]]; then
    url=$(playerctl metadata xesam:url 2>/dev/null)

    case "${url,,}" in
    *.mp4 | *.mkv | *.webm | *.avi | *.mov | *.m4v | *.flv | *.wmv | *.mpeg | *.mpg | *.ts | *.m2ts)
      if [[ "$video" == false ]]; then
        get_swayidle_pid
        kill_swayidle
        video=true
      fi
      ;;
    *)
      video=false
      ;;
    esac
  else
    if [[ "$video" == true ]]; then
      video=false
      start_swayidle
    fi
  fi

  sleep 2
done