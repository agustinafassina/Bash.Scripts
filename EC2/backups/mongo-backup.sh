#!/bin/bash
now=$(date +%m%d%Y%H%M%S)
folderBackupPath="/home/ubuntu/mongodb_backups"
bucketPathS3="s3-backup-name/backuptest/"
backupPathEc2=~/mongodb_backups
completeBackupPath="$backupPathEc2/$now"

# Create folder if not exists
mkdir -p "$completeBackupPath"

# Create mongodb backup
mongodump --out "$completeBackupPath"

# Copy to S3
aws s3 cp "$folderBackupPath" "s3://$bucketPathS3" --recursive

# Remove backup
rm -rf "$folderBackupPath"