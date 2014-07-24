#!/bin/bash
#set -x
BKPDIR=/mnt/backup/6380
S3DESTINATION=s3://backups/Redis/6380/
LOGDIR=/var/log/redis_s3
LOG=$LOGDIR/6380-`date +"%d%m%Y-%H%M%S"`.log

echo "--- Iniciado em `date` ---" > $LOG 2>&1
cd $BLPDIR >> $LOG 2>&1

for REDIS in `find $BKPDIR -maxdepth 1 -type f`; do  >> $LOG 2>&1
/usr/bin/s3cmd --config=/home/ubuntu/.s3cfg put $REDIS $S3DESTINATION --progress -v && mv $REDIS{,.DONE}  >> $LOG 2>&1
rm $REDIS.DONE  >> $LOG 2>&1
done  >> $LOG 2>&1
echo "--- Finalizado em `date` ---"  >> $LOG 2>&1

for logs in `find $LOGDIR -mtime +7`; do
rm -rf ${logs}
done