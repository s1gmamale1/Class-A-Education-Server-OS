#!/bin/bash

THRESHOLD=80
LOGFILE="/var/classa/app/logs/disk_alerts.log"
HOSTNAME=$(hostname)

# Default bot token used when user does not provide their own.
# Replace this with your default coursework bot token if you have one.
DEFAULT_BOT_TOKEN="8755151887:AAFen7m89xP6CYhS0934G7VHXFQGUw7Z4bg"

echo "Class A Education Disk Alert Setup"
echo "----------------------------------"

read -p "Do you have your own Telegram bot token? (y/n): " HAS_TOKEN

if [[ "$HAS_TOKEN" == "y" || "$HAS_TOKEN" == "Y" ]]; then
    read -p "Enter your Telegram bot token: " BOT_TOKEN
    read -p "Enter your Telegram chat ID: " CHAT_ID
else
    BOT_TOKEN="$DEFAULT_BOT_TOKEN"
    read -p "Enter your Telegram user/chat ID: " CHAT_ID
    echo "Please go to telegram and /start bot @Viper_worker_bot"
fi

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    MESSAGE="ALERT: Low disk space on [$HOSTNAME]. Current usage: $DISK_USAGE%"

    echo "----------------------------------------------------"
    echo "$MESSAGE"
    echo "----------------------------------------------------"

    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | sudo tee -a "$LOGFILE" >/dev/null

    if [[ "$BOT_TOKEN" != "PASTE_DEFAULT_BOT_TOKEN_HERE" && -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -d "chat_id=$CHAT_ID" \
            -d "text=$MESSAGE" >/dev/null

        echo "Telegram notification sent."
    else
        echo "Telegram notification skipped: bot token not configured."
    fi
else
    MESSAGE="STATUS: Disk space OK on [$HOSTNAME]. Used: $DISK_USAGE%"

    echo "$MESSAGE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | sudo tee -a "$LOGFILE" >/dev/null

    if [[ "$BOT_TOKEN" != "PASTE_DEFAULT_BOT_TOKEN_HERE" && -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
            -d "chat_id=$CHAT_ID" \
            -d "text=$MESSAGE" >/dev/null

        echo "Telegram status notification sent."
    else
        echo "Telegram notification skipped: bot token not configured."
    fi
fi
