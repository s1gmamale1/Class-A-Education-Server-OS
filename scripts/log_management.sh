#!/bin/bash

LOG_DIR="/var/classa/app/logs"
BACKUP_DIR="/var/classa/app/backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Starting log rotation..."

for logfile in "$LOG_DIR/system_monitor.log" "$LOG_DIR/disk_alerts.log" "$LOG_DIR/server.log"; do
    if [ -f "$logfile" ]; then
        gzip -c "$logfile" > "$logfile-$TIMESTAMP.gz"
        sudo truncate -s 0 "$logfile"
        echo "Rotated and compressed: $logfile"
    fi
done

sudo mv "$LOG_DIR"/*.gz "$BACKUP_DIR/" 2>/dev/null

sudo find "$BACKUP_DIR" -name "*.gz" -mtime +"$RETENTION_DAYS" -exec rm {} \;

echo "$(date '+%Y-%m-%d %H:%M:%S') Log rotation completed." | sudo tee -a "$LOG_DIR/rotation.log" >/dev/null

echo "Log rotation and backup completed successfully."
