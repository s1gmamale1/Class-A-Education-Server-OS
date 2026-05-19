#!/bin/bash

BASE="/var/classa"

echo "Creating Class A directory structure..."

sudo mkdir -p "$BASE/course_materials"
sudo mkdir -p "$BASE/uploads_exchange"
sudo mkdir -p "$BASE/app/config"
sudo mkdir -p "$BASE/app/logs"
sudo mkdir -p "$BASE/app/data"
sudo mkdir -p "$BASE/app/backups"

echo "Creating sample files..."

echo "Class A public course material: Lesson 1" | sudo tee "$BASE/course_materials/lesson1.txt" >/dev/null
echo "Platform rules and student guide" | sudo tee "$BASE/course_materials/rules.txt" >/dev/null

echo "Database connection settings placeholder" | sudo tee "$BASE/app/config/settings.conf" >/dev/null
echo "Class A application log started" | sudo tee "$BASE/app/logs/server.log" >/dev/null
echo "Sample homework session data" | sudo tee "$BASE/app/data/homework_session.txt" >/dev/null

echo "Setting ownership..."

sudo chown -R platform_admin:classa_staff "$BASE"

echo "Setting permissions..."

# Course materials: readable by everyone, writable by owner only
sudo chmod 755 "$BASE/course_materials"
sudo chmod 644 "$BASE/course_materials/"*

# Upload exchange: everyone in group can create files, sticky bit prevents deleting others' files
sudo chmod 1770 "$BASE/uploads_exchange"
sudo chown platform_admin:classa_staff "$BASE/uploads_exchange"

# Config: only admin/root style access
sudo chmod 700 "$BASE/app/config"
sudo chmod 600 "$BASE/app/config/settings.conf"

# Logs: admin and group can read/access
sudo chmod 750 "$BASE/app/logs"
sudo chmod 640 "$BASE/app/logs/server.log"

# Data: group can access, outsiders cannot
sudo chmod 750 "$BASE/app/data"
sudo chmod 640 "$BASE/app/data/homework_session.txt"

# Backups: admin only
sudo chmod 700 "$BASE/app/backups"

echo "Creating symbolic links..."

sudo ln -sfn "$BASE/course_materials" /home/support_user/classa_materials
sudo ln -sfn "$BASE/uploads_exchange" /home/support_user/classa_uploads

sudo chown -h support_user:support_user /home/support_user/classa_materials
sudo chown -h support_user:support_user /home/support_user/classa_uploads

echo "Class A file structure is ready."
