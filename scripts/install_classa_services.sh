#!/bin/bash
#
# install_classa_services.sh — install the two core packages for Class A Education:
#   Nginx (web server / reverse proxy) and PostgreSQL (relational database).
# Also installs the helper tools the other scripts rely on (curl, bc, gzip).
#
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
sudo apt update

echo "Installing Nginx, PostgreSQL and helper tools..."
sudo apt install -y nginx postgresql postgresql-contrib curl bc gzip

echo "Enabling and starting services..."
sudo systemctl enable --now nginx
sudo systemctl enable --now postgresql

echo "--------------------------------"
sudo systemctl is-active --quiet nginx      && echo "Nginx status: Active"      || echo "Nginx status: FAILED"
sudo systemctl is-active --quiet postgresql && echo "PostgreSQL status: Active" || echo "PostgreSQL status: FAILED"
echo "--------------------------------"
nginx -v
psql --version

echo "Class A Education services installation completed."
