#!/bin/sh

mkdir /home/user/bkpmysql/backups
export BACKUP_FILE=/home/user/bkpmysql/backups/db-backup.sql.gz
export DATABASE_SCHEMA_NAME=--all-databases
export AZURE_CONTAINER=YOUR_VALUE_HERE
export AZURE_STORAGE_NAME=YOUR_VALUE_HERE
export AZURE_KEY='YOUR_VALUE_HERE'
export AZURE_BLOB_NAME=db-production-$(date +%Y%m%d%H%M%S).sql.gz

/bin/mysqldump $DATABASE_SCHEMA_NAME > temp.sql
gzip temp.sql
rm -rf $BACKUP_FILE
mv temp.sql.gz $BACKUP_FILE
azure storage blob upload --container $AZURE_CONTAINER -f $BACKUP_FILE -b $AZURE_BLOB_NAME  -a $AZURE_STORAGE_NAME -k $AZURE_KEY