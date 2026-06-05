#!/bin/bash
#
# monitor.sh — Class A Education system monitor
# Collects CPU, memory and disk usage and appends a timestamped line to the log.
# Designed to run unattended from cron (see setup_cron.sh).
#
set -uo pipefail
export LC_ALL=C   # force '.' as decimal separator so parsing is locale-independent

# Re-run as root if needed (so we can always write under /var/classa). When cron
# runs this as root the check is skipped; a manual run will prompt once for sudo.
if [[ $EUID -ne 0 ]]; then exec sudo "$0" "$@"; fi

LOG_DIR="/var/classa/app/logs"
LOGFILE="$LOG_DIR/system_monitor.log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# CPU usage = 100 - idle%. Pull the idle ("id") field out of `top` without needing
# the external `bc` tool — awk does the arithmetic.
CPU_IDLE=$(top -bn1 | awk -F',' '/[Cc]pu\(s\)/{
    for (i = 1; i <= NF; i++)
        if ($i ~ /id/) { gsub(/[^0-9.]/, "", $i); print $i; exit }
}')
CPU_USAGE=$(awk -v idle="${CPU_IDLE:-0}" 'BEGIN { printf "%.1f", 100 - idle }')

# Memory: used/total in MB plus percentage.
MEM_USAGE=$(free -m | awk 'NR==2{printf "Memory: %s/%sMB (%.2f%%)", $3, $2, ($2>0 ? $3*100/$2 : 0)}')

# Disk: usage percentage of the root filesystem.
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}')

echo "[$TIMESTAMP] CPU: ${CPU_USAGE}% | $MEM_USAGE | Disk: $DISK_USAGE" >> "$LOGFILE"
