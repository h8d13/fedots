#!/bin/bash
# swaybar status_command: one line per update, segments only when available
# bash builtins only, so ticks fork nothing (one fork at startup for the sleep fd)

# sleep without forking: read -t on a pipe that never gets data
exec {sleep_fd}<> <(:)

prev_total=0 prev_idle=0

while :; do
    line=""

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
    if [ "$prev_total" -gt 0 ] && [ "$dt" -gt 0 ]; then
        cpu="$(( (100 * (dt - (idle - prev_idle)) + dt / 2) / dt ))%"
    else
        cpu="--"  # first tick: no interval to measure yet
    fi
    prev_total=$total prev_idle=$idle
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
