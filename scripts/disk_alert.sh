#!/bin/bash

THRESHOLD=80
LOGFILE="/var/classa/app/logs/disk_alergs.log"
HOSTNAME=$(hostname)

BOT_TOKEN="8755151887:AAFen7m89xP6CYhS0934G7VHXFQGUw7Z4bg"
CHAT_ID="695707378"

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    MESSAGE="ALERT: Low disk space on [$HOSTNAME]. Current usage: $DISK_USAGE%"

    echo "----------------------------------------------------"
    echo "$MESSAGE"
    echo "----------------------------------------------------"

    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | sudo tee -a "$LOGFILE" >/dev/null

    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$MESSAGE" >/dev/null

    echo "Telegram notification sent."
else
    MESSAGE="STATUS: Disk space OK on [$HOSTNAME]. Used: $DISK_USAGE%"
    echo "$MESSAGE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | sudo tee -a "$LOGFILE" >/dev/null
fi
