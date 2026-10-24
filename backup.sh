#!/bin/bash
# backup.sh - Backs up the PostgreSQL database and the Drupal sites folder.

DB_CONTAINER="drupal-db"
WEB_CONTAINER="drupal-web"
DB_USER="root"
DB_NAME="drupal"
DB_BACKUP="drupal_db_backup.sql"
SITES_BACKUP="drupal_sites_backup.tar.gz"

echo "=== Drupal backup ==="

# Make sure the containers are running
for c in "$DB_CONTAINER" "$WEB_CONTAINER"; do
  if ! docker ps --format '{{.Names}}' | grep -qx "$c"; then
    echo "[ERROR] Container '$c' is not running. Run ./setup.sh first."
    exit 1
  fi
done

# 1. Database
echo "[..] Backing up database '$DB_NAME'"
if docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$DB_BACKUP"; then
  echo "[OK] Database saved to $DB_BACKUP"
else
  echo "[ERROR] Database backup failed"
  exit 1
fi

# 2. Drupal sites folder
echo "[..] Backing up Drupal sites folder"
if docker exec "$WEB_CONTAINER" tar czf - -C /var/www/html sites > "$SITES_BACKUP"; then
  echo "[OK] Sites folder saved to $SITES_BACKUP"
else
  echo "[ERROR] Sites backup failed"
  exit 1
fi

echo ""
echo "=== Backup complete ==="
ls -lh "$DB_BACKUP" "$SITES_BACKUP"
