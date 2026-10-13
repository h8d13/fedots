#!/bin/sh
# swaybar status_command: one line per update, segments only when available

while :; do
    line=""

    # battery
    for bat in /sys/class/power_supply/BAT*; do
        [ -r "$bat/capacity" ] || continue
        cap=$(cat "$bat/capacity")
        [ "$(cat "$bat/status")" = "Charging" ] && cap="$cap+"
        line="$line bat $cap% |"
    done

    # memory used
    mem=$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf "%.1fG", (t-a)/1048576}' /proc/meminfo)
    line="$line mem $mem |"

    # load
    read -r load _ </proc/loadavg
    line="$line load $load |"

    echo "$line $(date +'%Y-%m-%d %H:%M') "
    sleep 5
done
