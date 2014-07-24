#!/bin/bash
# Call this script for Redis Backup
# Usage: sh backup_redis backup-folder-path
#

REDIS_SOURCE=$1
BACKUP_DIR=$2

BACKUP_PREFIX="redis.dump.rdb"
DAY=`date +"%d%m%Y-%H%M%S"`
REDIS_DEST="$BACKUP_DIR/$BACKUP_PREFIX.$DAY"

cp $REDIS_SOURCE $REDIS_DEST