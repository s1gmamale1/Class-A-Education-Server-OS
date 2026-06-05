#!/bin/bash
#
# setup_cron.sh — install the Class A Education scheduled jobs automatically.
#
# Schedules (installed into ROOT's crontab so the jobs run with the privileges
# they need — no interactive sudo inside cron):
#   monitor.sh         every 5  minutes   (system monitoring at regular intervals)
#   disk_alert.sh      every 15 minutes   (homework uploads can fill disk quickly)
#   log_management.sh  daily at 00:00     (rotate/compress/back up logs)
#
# Paths are derived from THIS script's own location, so the jobs always point at
# the real scripts (no hard-coded /home/<user>/... that breaks if the repo moves).
#
set -euo pipefail

# Re-run as root so we edit root's crontab.
if [[ $EUID -ne 0 ]]; then exec sudo "$0" "$@"; fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MON="$SCRIPT_DIR/monitor.sh"
DISK="$SCRIPT_DIR/disk_alert.sh"
LOGR="$SCRIPT_DIR/log_management.sh"
TAG="# CLASS_A_CRON"

chmod +x "$MON" "$DISK" "$LOGR"

# --- Install/refresh entries in root's crontab (idempotent) ---
tmp=$(mktemp)
crontab -l 2>/dev/null | grep -v "$TAG" > "$tmp" || true
cat >> "$tmp" <<EOF
*/5 * * * * $MON $TAG
*/15 * * * * $DISK $TAG
0 0 * * * $LOGR $TAG
EOF
crontab "$tmp"
rm -f "$tmp"

# --- Remove any stale Class A entries the user may have added manually elsewhere ---
INVOKER="${SUDO_USER:-}"
if [[ -n "$INVOKER" ]] && crontab -u "$INVOKER" -l >/dev/null 2>&1; then
    crontab -u "$INVOKER" -l 2>/dev/null \
        | grep -vE "($TAG|coursework/scripts/(monitor|disk_alert|log_management)\.sh)" \
        | crontab -u "$INVOKER" - || true
    echo "Cleaned any stale Class A entries from ${INVOKER}'s crontab."
fi

echo "Installed Class A cron jobs (root):"
crontab -l | grep "$TAG"
echo "Cron setup completed."
