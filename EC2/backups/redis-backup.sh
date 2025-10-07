#!/bin/bash
# Redis stop
sudo systemctl stop redis
# Create backup
BACKUP_FILE="/tmp/redis-backup-$(date +%F).rdb"
BACKUP_S3_PATH="s3://backups/api/dev/"
BACKUP_S3_PATH_COMPLETE="${BACKUP_S3_PATH}$(date +%Y%m%d%H%M%S)/"

sudo cp /var/lib/redis/dump.rdb "$BACKUP_FILE"
# Redis start
sudo systemctl start redis
# Upload to s3
aws s3 cp "$BACKUP_FILE" "$BACKUP_S3_PATH_COMPLETE"
# Options: remove local backup after upload
