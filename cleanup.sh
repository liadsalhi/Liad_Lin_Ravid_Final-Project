#!/bin/bash
# cleanup.sh - Removes everything created by setup.sh and
# leaves the machine as it was before the project started.

NETWORK_NAME="drupal-net"
DB_CONTAINER="drupal-db"
WEB_CONTAINER="drupal-web"
DB_IMAGE="postgres:latest"
WEB_IMAGE="drupal:latest"
DB_VOLUME="drupal-db-data"
SITES_VOLUME="drupal-sites"

echo "=== Drupal + PostgreSQL cleanup ==="

# 1. Containers
for c in "$WEB_CONTAINER" "$DB_CONTAINER"; do
  if docker ps -a --format '{{.Names}}' | grep -qx "$c"; then
    docker rm -f "$c" >/dev/null
    echo "[OK] Removed container '$c'"
  else
    echo "[--] Container '$c' not found, skipping"
  fi
done

# 2. Volumes
for v in "$DB_VOLUME" "$SITES_VOLUME"; do
  if docker volume inspect "$v" >/dev/null 2>&1; then
    docker volume rm "$v" >/dev/null
    echo "[OK] Removed volume '$v'"
  else
    echo "[--] Volume '$v' not found, skipping"
  fi
done

# 3. Images
for i in "$WEB_IMAGE" "$DB_IMAGE"; do
  if docker image inspect "$i" >/dev/null 2>&1; then
    docker rmi "$i" >/dev/null
    echo "[OK] Removed image '$i'"
  else
    echo "[--] Image '$i' not found, skipping"
  fi
done

# 4. Network
if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  docker network rm "$NETWORK_NAME" >/dev/null
  echo "[OK] Removed network '$NETWORK_NAME'"
else
  echo "[--] Network '$NETWORK_NAME' not found, skipping"
fi

echo ""
echo "=== Cleanup complete ==="
docker ps -a
