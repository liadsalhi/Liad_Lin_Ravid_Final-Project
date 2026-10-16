#!/bin/bash
# setup.sh - Builds the Docker infrastructure for the Drupal site:
# a private network, a PostgreSQL container and a Drupal container.

set -e

NETWORK_NAME="drupal-net"
DB_CONTAINER="drupal-db"
WEB_CONTAINER="drupal-web"
DB_IMAGE="postgres:latest"
WEB_IMAGE="drupal:latest"
DB_VOLUME="drupal-db-data"
SITES_VOLUME="drupal-sites"
DB_NAME="drupal"
DB_USER="root"
DB_PASSWORD="my-secret-pw"

container_exists() {
  docker ps -a --format '{{.Names}}' | grep -qx "$1"
}

echo "=== Drupal + PostgreSQL setup ==="

# 1. Network
if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "[OK] Network '$NETWORK_NAME' already exists"
else
  docker network create "$NETWORK_NAME" >/dev/null
  echo "[OK] Created network '$NETWORK_NAME'"
fi

# 2. Latest images
echo "[..] Pulling latest images (this can take a few minutes)"
docker pull "$DB_IMAGE"
docker pull "$WEB_IMAGE"

# 3. Database container
if container_exists "$DB_CONTAINER"; then
  docker start "$DB_CONTAINER" >/dev/null
  echo "[OK] Container '$DB_CONTAINER' already exists - started"
else
  docker run -d \
    --name "$DB_CONTAINER" \
    --network "$NETWORK_NAME" \
    -e POSTGRES_USER="$DB_USER" \
    -e POSTGRES_PASSWORD="$DB_PASSWORD" \
    -e POSTGRES_DB="$DB_NAME" \
    -p 5432:5432 \
    -v "$DB_VOLUME":/var/lib/postgresql \
    "$DB_IMAGE" >/dev/null
  echo "[OK] Started PostgreSQL container '$DB_CONTAINER'"
fi

echo "[..] Waiting for PostgreSQL to accept connections"
until docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do
  sleep 2
done
echo "[OK] PostgreSQL is ready"

# 4. Drupal container
if container_exists "$WEB_CONTAINER"; then
  docker start "$WEB_CONTAINER" >/dev/null
  echo "[OK] Container '$WEB_CONTAINER' already exists - started"
else
  docker run -d \
    --name "$WEB_CONTAINER" \
    --network "$NETWORK_NAME" \
    -p 8080:80 \
    -v "$SITES_VOLUME":/var/www/html/sites \
    "$WEB_IMAGE" >/dev/null
  echo "[OK] Started Drupal container '$WEB_CONTAINER'"
fi

echo ""
echo "=== Setup complete ==="
echo "Open http://localhost:8080 in the browser"
docker ps
