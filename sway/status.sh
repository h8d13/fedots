#!/bin/bash
# swaybar status_command: one line per update, segments only when available
# bash builtins only, so ticks fork nothing (one fork at startup for the sleep fd)

# sleep without forking: read -t on a pipe that never gets data
exec {sleep_fd}<> <(:)

# volume: asking wpctl costs a fork, so only do it at startup and on USR1
# (sway's volume keys send it). The handler also writes a newline into the
# sleep pipe: bash restarts an interrupted read -t *without* its timeout,
# so this both wakes the loop for an instant redraw and avoids hanging.
vol=""
read_vol() {
    local _ level muted
    read -r _ level muted <<<"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"
    [ -n "$level" ] || { vol=""; return; }
    vol="$((10#${level/./}))%"
    [ -n "$muted" ] && vol="muted"
}
if command -v wpctl >/dev/null; then
    read_vol
    trap 'read_vol; echo >&"$sleep_fd"' USR1
fi

# brightness is read from sysfs every tick (no fork); USR2 only wakes the loop
trap 'echo >&"$sleep_fd"' USR2

prev_total=0 prev_idle=0

while :; do
    line=""

    [ -n "$vol" ] && line="$line vol $vol |"

    # brightness
    for bl in /sys/class/backlight/*; do
        [ -r "$bl/brightness" ] || continue
        read -r cur <"$bl/brightness"
        read -r max <"$bl/max_brightness"
        [ "$max" -gt 0 ] && line="$line bri $(( (100 * cur + max / 2) / max ))% |"
        break  # first panel only
    done

    # battery
    for bat in /sys/class/power_supply/BAT*; do
        [ -r "$bat/capacity" ] || continue
        read -r cap <"$bat/capacity"
        read -r state <"$bat/status"
        [ "$state" = "Charging" ] && cap="$cap+"
        line="$line bat $cap% |"
    done

    # cpu usage since last tick (first line of /proc/stat is the all-cpu sum)
    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle=$((idle + iowait))
    dt=$((total - prev_total))
    if [ "$prev_total" -eq 0 ]; then
        cpu="--"  # first tick: no interval to measure yet
        prev_total=$total prev_idle=$idle
    elif [ "$dt" -ge 100 ]; then  # skip too-short intervals (signal redraws)
        cpu="$(( (100 * (dt - (idle - prev_idle)) + dt / 2) / dt ))%"
        prev_total=$total prev_idle=$idle
    fi
    line="$line cpu $cpu |"

    # memory used (MemTotal - MemAvailable, kB -> G with one decimal)
    while read -r key val _; do
        case $key in
            MemTotal:) mem_total=$val ;;
            MemAvailable:) mem_avail=$val; break ;;
        esac
    done </proc/meminfo
    used=$(( (mem_total - mem_avail) * 10 / 1048576 ))
    line="$line mem $((used / 10)).$((used % 10))G |"

    # load
    read -r load _ </proc/loadavg
    line="$line load $load |"

    printf -v now '%(%Y-%m-%d %H:%M)T' -1
    echo "$line $now "
    read -rt 5 -u "$sleep_fd"
done
