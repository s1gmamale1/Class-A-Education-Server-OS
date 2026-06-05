#!/bin/bash
#
# docker_manage.sh — demonstrates the full Docker container lifecycle:
#   list, logs, port mapping, volumes, stop and remove.
# Builds the classa-web-app image first if it is not present.
#
set -uo pipefail

# Use docker without sudo when possible, otherwise fall back to sudo.
DOCKER="docker"
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

IMAGE="classa-web-app"
CONTAINER="classa-managed-container"
PORT=8081
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(cd "$SCRIPT_DIR/../docker-web" && pwd)"

# Build the image if it does not exist yet (B.9 build step).
if ! $DOCKER image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Image '$IMAGE' not found — building from $WEB_DIR ..."
    $DOCKER build -t "$IMAGE" "$WEB_DIR"
fi

echo "Removing old managed container if it exists..."
$DOCKER rm -f "$CONTAINER" 2>/dev/null || true

echo "Creating Docker volume (persistent data)..."
$DOCKER volume create classa_data >/dev/null

echo "Running container with port mapping and volume..."
$DOCKER run -d \
    -p ${PORT}:80 \
    --name "$CONTAINER" \
    -v classa_data:/usr/share/nginx/html \
    "$IMAGE"

echo "== Running containers =="
$DOCKER ps
echo "== Container logs =="
$DOCKER logs "$CONTAINER"
echo "== All containers (including stopped) =="
$DOCKER ps -a
echo "== Docker volumes =="
$DOCKER volume ls
echo "== Port mapping =="
$DOCKER port "$CONTAINER"

echo "Stopping container..."
$DOCKER stop "$CONTAINER"
echo "Removing container..."
$DOCKER rm "$CONTAINER"

echo "Docker management operations completed."
