#!/bin/bash
#
# install_docker.sh — install Docker Engine on Ubuntu and verify it.
# Uses Docker's official install script (detects distro/arch automatically),
# enables the service, and lets the current user run docker without sudo.
#
set -euo pipefail

echo "Installing prerequisites..."
sudo apt update
sudo apt install -y curl ca-certificates

echo "Installing Docker Engine (official get.docker.com script)..."
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh
rm -f /tmp/get-docker.sh

echo "Enabling and starting Docker..."
sudo systemctl enable --now docker

# Allow the invoking user to use docker without sudo (takes effect after re-login).
TARGET_USER="${SUDO_USER:-$USER}"
sudo usermod -aG docker "$TARGET_USER"
echo "Added '$TARGET_USER' to the 'docker' group — log out/in (or run: newgrp docker) to apply."

echo "--------------------------------"
echo "Docker version:"
sudo docker --version
echo "Verifying installation with hello-world:"
sudo docker run --rm hello-world

echo "Docker installation and verification completed."
