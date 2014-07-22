#!/bin/bash
# Call this script for Redis Backup
# Usage: sh log_organizer log-name log-folder-path
#

LOG_NAME=$1
LOG_PATH=$2

DAY=`date '+%F.%T'`
LOG_DEST="$LOG_PATH/$LOG_NAME.$DAY.old"

cp $LOG_PATH/$LOG_NAME $LOG_DEST

truncate -s0 $LOG_PATH/$LOG_NAME