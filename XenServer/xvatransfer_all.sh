#!/bin/bash

# Script for sending files to a XVA S3 Bucket 
# This script takes all the files in the folder /mnt/backup, sends to S3, and then removes locally. 
# After sending, adds the extension. DONE on file for error control in case of failure in upload. Thus, not delete files which upload was not complete.
# Ricardo Martins - http://www.ricardomartins.com.br


XVADIR=/mnt/backup
S3DESTINATION=s3://xenbackup
LOGDIR=/var/log/backupxen/xvatransfer
LOG=$LOGDIR/xvatransfer-`date +"%d%m%Y-%H%M%S"`.log

echo "--- Iniciado em `date` ---" > $LOG 2>&1
cd $XVADIR >> $LOG 2>&1

for XVA in `find $XVADIR -maxdepth 1 -type f`; do  >> $LOG 2>&1
/usr/bin/s3cmd --config=/root/.s3cfg put $XVA $S3DESTINATION --progress -v && mv $XVA{,.DONE}  >> $LOG 2>&1
rm $XVA.DONE  >> $LOG 2>&1
done  >> $LOG 2>&1
echo "--- Finalizado em `date` ---"  >> $LOG 2>&1

