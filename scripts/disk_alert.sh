#!/bin/bash
#
# disk_alert.sh — Class A Education low-disk-space monitor
# Sends alerts through THREE channels when the root filesystem crosses the
# threshold: (1) terminal + OS broadcast, (2) file log, (3) Telegram.
#
# Runs unattended from cron (config comes from /etc/classa/alert.conf).
# Interactive first-time setup:   sudo ./disk_alert.sh --setup
#
set -uo pipefail
export LC_ALL=C

# Re-run as root if needed (write logs, broadcast with `wall`).
if [[ $EUID -ne 0 ]]; then exec sudo "$0" "$@"; fi

# ---------------------------------------------------------------- defaults ---
THRESHOLD=80
LOG_DIR="/var/classa/app/logs"
LOGFILE="$LOG_DIR/disk_alerts.log"
CONFIG_FILE="/etc/classa/alert.conf"
HOST=$(hostname)

# Shared coursework Telegram bot — students who have not configured their own bot
# still receive alerts. Override BOT_TOKEN/CHAT_ID/THRESHOLD in $CONFIG_FILE.
BOT_TOKEN="8755151887:AAFen7m89xP6CYhS0934G7VHXFQGUw7Z4bg"
CHAT_ID=""

# Load saved overrides if present.
# shellcheck source=/dev/null
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

mkdir -p "$LOG_DIR"

# ----------------------------------------------------- interactive --setup ---
if [[ "${1:-}" == "--setup" ]]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    read -rp "Use your OWN Telegram bot token? (y/N): " own
    if [[ "$own" =~ ^[Yy]$ ]]; then
        read -rp "Enter your bot token: " BOT_TOKEN
    else
        echo "Using the shared coursework bot — open Telegram and press START on @Viper_worker_bot"
    fi
    read -rp "Enter your Telegram chat/user ID: " CHAT_ID
    umask 077
    cat > "$CONFIG_FILE" <<EOF
# Class A Education disk-alert configuration
THRESHOLD=$THRESHOLD
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
EOF
    chmod 600 "$CONFIG_FILE"
    echo "Saved configuration to $CONFIG_FILE"
    exit 0
fi

# ----------------------------------------------------------------- measure ---
USAGE=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
USAGE=${USAGE:-0}
TS=$(date '+%Y-%m-%d %H:%M:%S')

send_telegram() {
    local msg="$1"
    if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
        echo "Telegram skipped (no CHAT_ID — run: sudo $0 --setup)"
        return
    fi
    if curl -fsS -m 10 -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$CHAT_ID" \
        --data-urlencode "text=$msg" >/dev/null; then
        echo "Telegram notification sent."
    else
        echo "Telegram notification failed."
    fi
}

# ------------------------------------------------------------ alert / status -
if (( USAGE > THRESHOLD )); then
    MSG="ALERT [$HOST]: disk usage ${USAGE}% exceeds ${THRESHOLD}% threshold ($TS)"

    echo "----------------------------------------------------"
    echo "$MSG"                                      # 1a. terminal
    echo "----------------------------------------------------"
    command -v wall        >/dev/null 2>&1 && echo "$MSG" | wall 2>/dev/null          # 1b. OS broadcast
    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "Class A Disk Alert" "$MSG" 2>/dev/null

    echo "$TS $MSG" >> "$LOGFILE"                    # 2. file log
    send_telegram "$MSG"                             # 3. Telegram
else
    MSG="STATUS [$HOST]: disk usage OK at ${USAGE}% (threshold ${THRESHOLD}%) ($TS)"
    echo "$MSG"                                      # terminal
    echo "$TS $MSG" >> "$LOGFILE"                    # file log (no Telegram spam when healthy)
fi
