#!/bin/bash

LOGFILE="/var/classa/app/logs/system_monitor.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)

MEM_USAGE=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)", $3,$2,$3*100/$2}')

DISK_USAGE=$(df -h / | awk 'NR==2{print $5}')

echo "[$TIMESTAMP] CPU: $CPU_USAGE% | $MEM_USAGE | Disk: $DISK_USAGE" | sudo tee -a "$LOGFILE" >/dev/null
