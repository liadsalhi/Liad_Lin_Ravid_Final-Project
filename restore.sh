#!/bin/bash
# restore.sh - Restores the Drupal site from the backup files in this repository:
# the PostgreSQL dump and the Drupal "sites" folder (settings.php + files).

set -e
cd "$(dirname "$0")"

DB_CONTAINER="drupal-db"
WEB_CONTAINER="drupal-web"
DB_USER="root"
DB_NAME="drupal"
DB_BACKUP="drupal_db_backup.sql"
SITES_BACKUP="drupal_sites_backup.tar.gz"

is_running() {
  docker ps --format '{{.Names}}' | grep -qx "$1"
}

echo "=== Drupal restore ==="

# 1. Get the latest backup from Git
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[..] Pulling the latest backup from Git"
  git pull || echo "[WARN] git pull failed - using the local backup files"
fi

for f in "$DB_BACKUP" "$SITES_BACKUP"; do
  if [ ! -s "$f" ]; then
    echo "[ERROR] Backup file '$f' is missing or empty"
    exit 1
  fi
done

# 2. Make sure the containers are running
if ! is_running "$DB_CONTAINER" || ! is_running "$WEB_CONTAINER"; then
  echo "[..] Containers are not running - starting them with setup.sh"
  ./setup.sh
fi

echo "[..] Waiting for PostgreSQL"
until docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" >/dev/null 2>&1; do
  sleep 2
done

# 3. Database: recreate it empty, then load the dump
echo "[..] Recreating database '$DB_NAME'"
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d postgres -q \
  -c "DROP DATABASE IF EXISTS \"$DB_NAME\" WITH (FORCE);" \
  -c "CREATE DATABASE \"$DB_NAME\";"

echo "[..] Loading $DB_BACKUP"
docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -q "$DB_NAME" < "$DB_BACKUP" >/dev/null
echo "[OK] Database restored"

# 4. Drupal sites folder (settings.php and uploaded files)
echo "[..] Restoring Drupal sites folder"
docker exec -i "$WEB_CONTAINER" tar xzf - -C /var/www/html < "$SITES_BACKUP"
docker exec "$WEB_CONTAINER" chown -R www-data:www-data /var/www/html/sites/default/files 2>/dev/null || true
echo "[OK] Sites folder restored"

# 5. Restart Drupal so the changes take effect
docker restart "$WEB_CONTAINER" >/dev/null
echo "[OK] Drupal restarted"

echo ""
echo "=== Restore complete ==="
echo "Open http://localhost:8080 and log in as demoadmin / secretpass"

