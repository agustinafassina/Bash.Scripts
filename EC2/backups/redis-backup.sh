#!/bin/bash
# v2.0
sudo systemctl stop redis
# Create backup
backup_file="/tmp/redis-backup-$(date +%F).rdb"
backup_s3_path="s3://backups/api/dev/"
backup_s3_path_complete="${backup_s3_path}$(date +%Y%m%d%H%M%S)/"

sudo cp /var/lib/redis/dump.rdb "$backup_file"
# Redis start
sudo systemctl start redis
# Upload to s3
aws s3 cp "$backup_file" "$backup_s3_path_complete"
# Options: remove local backup after upload
