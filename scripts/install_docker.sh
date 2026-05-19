#!/bin/bash

echo "Installing Docker..."

sudo apt update
sudo apt install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

echo "Docker version:"
docker --version

echo "Running hello-world test:"
sudo docker run hello-world
