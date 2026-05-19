#!/bin/bash

echo "Removing old managed container if it exists..."
docker rm -f classa-managed-container 2>/dev/null

echo "Creating Docker volume..."
docker volume create classa_data

echo "Running container with port mapping and volume..."
docker run -d \
    -p 8081:80 \
    --name classa-managed-container \
    -v classa_data:/usr/share/nginx/html \
    classa-web-app

echo "Listing running containers..."
docker ps

echo "Viewing container logs..."
docker logs classa-managed-container

echo "Listing all containers..."
docker ps -a

echo "Listing Docker volumes..."
docker volume ls

echo "Showing port mapping..."
docker port classa-managed-container

echo "Stopping container..."
docker stop classa-managed-container

echo "Removing container..."
docker rm classa-managed-container

echo "Docker management operations completed."
