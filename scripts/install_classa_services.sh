#!/bin/bash

echo "Updating package list..."
sudo apt update

echo "Installing Ngninx and PostgreSQL..."
sudo apt install -y nginx postgresql postgresql-contrib

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Starting and enabling PostreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "--------------------------------"
sudo systemctl is-active --quiet nginx && echo "Nginx status: Active" || echo "Nginx status: Failed"
sudo systemctl is-active --quiet postgresql && echo "PostgreSQL status: Active" || echo "PostgreSQL status: Failed"

echo "--------------------------------"
nginx -v
postgresql --version

echo "Class A Education services installation completed."


