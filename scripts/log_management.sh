#!/bin/bash
#
# log_management.sh — Class A Education log rotation & backup
#   1. Rotate active logs into timestamped copies (runs daily via cron).
#   2. Compress rotated logs older than COMPRESS_AFTER_DAYS.
#   3. Move compressed (.gz) logs older than RETENTION_DAYS to backup storage.
#   4. Purge backups older than ARCHIVE_DAYS.
#
# Use `--force` to compress + archive everything immediately (handy for the demo).
#
set -uo pipefail
export LC_ALL=C

# Re-run as root if needed (logs live under root-owned /var/classa).
if [[ $EUID -ne 0 ]]; then exec sudo "$0" "$@"; fi

LOG_DIR="/var/classa/app/logs"
BACKUP_DIR="/var/classa/app/backups"
COMPRESS_AFTER_DAYS=1     # education platform: keep yesterday's logs handy, then compress
RETENTION_DAYS=7          # keep a week of compressed logs in the live log dir
ARCHIVE_DAYS=30           # keep a month of archives in backup, then purge
TS=$(date +%Y%m%d_%H%M%S)
LOGS=("system_monitor.log" "disk_alerts.log" "server.log")

FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

mkdir -p "$LOG_DIR" "$BACKUP_DIR"

echo "[log_management] Rotating active logs..."
for name in "${LOGS[@]}"; do
    f="$LOG_DIR/$name"
    if [[ -s "$f" ]]; then                 # only rotate non-empty logs
        cp -p "$f" "$f.$TS"                 # rotate: timestamped copy
        : > "$f"                            # truncate in place (keeps inode/permissions)
        echo "  rotated: $name -> $name.$TS"
    fi
done

echo "[log_management] Compressing rotated logs..."
if (( FORCE )); then
    find "$LOG_DIR" -maxdepth 1 -type f -name "*.[0-9]*" ! -name "*.gz" -exec gzip -f {} \; -print
else
    find "$LOG_DIR" -maxdepth 1 -type f -name "*.[0-9]*" ! -name "*.gz" \
        -mtime +"$COMPRESS_AFTER_DAYS" -exec gzip -f {} \; -print
fi

echo "[log_management] Moving old compressed logs to backup storage..."
if (( FORCE )); then
    find "$LOG_DIR" -maxdepth 1 -type f -name "*.gz" -exec mv -f {} "$BACKUP_DIR/" \; -print
else
    find "$LOG_DIR" -maxdepth 1 -type f -name "*.gz" \
        -mtime +"$RETENTION_DAYS" -exec mv -f {} "$BACKUP_DIR/" \; -print
fi

echo "[log_management] Purging backups older than ${ARCHIVE_DAYS} days..."
find "$BACKUP_DIR" -type f -name "*.gz" -mtime +"$ARCHIVE_DAYS" -delete

echo "$(date '+%Y-%m-%d %H:%M:%S') Log rotation completed (rotate/compress/backup/purge)." >> "$LOG_DIR/rotation.log"
echo "[log_management] Done."
