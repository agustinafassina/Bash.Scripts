#!/bin/bash
# v2.0
now=$(date +%m%d%Y%H%M%S)
folder_backup_path="/home/ubuntu/mongodb_backups"
bucket_path_S3="s3-backup-name/backuptest/"
backup_path_ec2=~/mongodb_backups
complete_backup_path="$backup_path_ec2/$now"

# Create folder if not exists
mkdir -p "$complete_backup_path"

# Create mongodb backup
mongodump --out "$complete_backup_path"

# Copy to S3
aws s3 cp "$folder_backup_path" "s3://$bucket_path_S3" --recursive

# Remove backup
rm -rf "$folder_backup_path"