#!/bin/bash
# Call this script with the backup file-path
# Usage: sh restore_redis file-path
#

/etc/init.d/redis_6379 stop

rm /mnt/redis/redis_6379.rdb
cp $1 /mnt/redis/dump.rdb

/etc/init.d/redis_6379 start