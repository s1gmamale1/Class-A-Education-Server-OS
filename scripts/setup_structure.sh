#!/bin/bash
#
# setup_structure.sh — Class A Education filesystem layout & permissions
#   /var/classa/course_materials  -> shared, readable by others (read-only)
#   /var/classa/uploads_exchange  -> group drop-box with sticky bit (no deleting others' files)
#   /var/classa/app/{config,logs,data,backups} -> app tree demonstrating a range of permissions
#   + 2 symbolic links in support_user's home
#
# Safe to re-run (idempotent).
#
set -euo pipefail

BASE="/var/classa"
GROUP_NAME="classa_staff"
OWNER="platform_admin"

# Make the script self-sufficient.
getent group "$GROUP_NAME" >/dev/null || sudo groupadd "$GROUP_NAME"

echo "Creating Class A directory structure..."
sudo mkdir -p "$BASE/course_materials" \
              "$BASE/uploads_exchange" \
              "$BASE/app/config" \
              "$BASE/app/logs" \
              "$BASE/app/data" \
              "$BASE/app/backups"

echo "Creating sample files..."
echo "Class A public course material: Lesson 1"   | sudo tee "$BASE/course_materials/lesson1.txt"      >/dev/null
echo "Platform rules and student guide"           | sudo tee "$BASE/course_materials/rules.txt"        >/dev/null
echo "Database connection settings placeholder"   | sudo tee "$BASE/app/config/settings.conf"          >/dev/null
echo "Class A application log started"            | sudo tee "$BASE/app/logs/server.log"               >/dev/null
echo "Sample homework session data"               | sudo tee "$BASE/app/data/homework_session.txt"     >/dev/null

echo "Setting ownership..."
sudo chown -R "$OWNER:$GROUP_NAME" "$BASE"

echo "Setting permissions..."
# Shared course materials: world-readable, read-only for others.
sudo chmod 755 "$BASE/course_materials"
sudo chmod 644 "$BASE/course_materials/"*

# Upload exchange: group members create files; sticky bit stops them deleting each other's.
sudo chmod 1770 "$BASE/uploads_exchange"
sudo chown "$OWNER:$GROUP_NAME" "$BASE/uploads_exchange"

# Application tree (4 subdirectories demonstrating a range of permission models).
sudo chmod 700 "$BASE/app/config";  sudo chmod 600 "$BASE/app/config/settings.conf"
sudo chmod 750 "$BASE/app/logs";    sudo chmod 640 "$BASE/app/logs/server.log"
sudo chmod 750 "$BASE/app/data";    sudo chmod 640 "$BASE/app/data/homework_session.txt"
sudo chmod 700 "$BASE/app/backups"

echo "Creating symbolic links..."
if id support_user >/dev/null 2>&1; then
    sudo ln -sfn "$BASE/course_materials" /home/support_user/classa_materials
    sudo ln -sfn "$BASE/uploads_exchange" /home/support_user/classa_uploads
    # NB: do NOT `chown -h` these links. On this system chown -h on a
    # symlink-to-directory dereferences and rewrites the TARGET's ownership
    # (reverting /var/classa/uploads_exchange to support_user). Symlink
    # ownership is cosmetic on Linux — the target's permissions govern access —
    # so leaving the links root-owned is correct and safe.
else
    echo "  (support_user not found — run manage_users.sh first to create the symlinks)"
fi

echo "Class A file structure is ready."
