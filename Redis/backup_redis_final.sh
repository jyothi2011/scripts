#!/bin/bash
REDIS_PORT=6377
REDIS_SOURCE=/var/redis/$REDIS_PORT
BACKUP_DIR=/mnt/backup/redis/$REDIS_PORT
S3DESTINATION=s3://backups/Redis/$REDIS_PORT/
LOGDIR=/var/log/redis_s3
LOG=$LOGDIR/$REDIS_PORT-`date +"%d%m%Y-%H%M%S"`.log
DAY=`date +"%d%m%Y-%H%M%S"`
RDB_FILE=$REDIS_SOURCE/redis_$REDIS_PORT.rdb
RDB_FILE2=$BACKUP_DIR/redis_$REDIS_PORT.rdb
RDB_TAR=$BACKUP_DIR/redis_$REDIS_PORT.rdb.$DAY.tar.gz

if [[ ! -e $BACKUP_DIR ]]; then
            mkdir -p $BACKUP_DIR
fi

if [[ ! -e $LOGDIR ]]; then
            mkdir -p $LOGDIR
fi

/usr/local/bin/redis-cli -p $REDIS_PORT bgsave > $LOG 2>&1

if [ $? !=  0 ]
then
   echo "Erro na execucao do bgsave" 
   echo "Houve um erro na execucao do BGSAVE" | mail -s "BGSAVE com erro em HOSTNAME:$REDIS_PORT" contato@ricardomartins.com.br
   exit 1
   
else

    echo "bgsave executado com sucesso!" >> $LOG 2>&1
	/bin/cp -pvr $RDB_FILE $BACKUP_DIR >> $LOG 2>&1
	cd $BACKUP_DIR
	/bin/tar czvf $RDB_TAR "redis_$REDIS_PORT.rdb" >> $LOG 2>&1
	/bin/rm -rf $RDB_FILE2 >> $LOG 2>&1

    # S3 Transfer
    echo "--- Iniciada transfencia em `date` ---" >> $LOG 2>&1
    /usr/bin/s3cmd --config=/root/.s3cfg put $RDB_TAR $S3DESTINATION --progress >> $LOG 2>&1
    echo "--- Finalizado envio em `date` ---"  >> $LOG 2>&1
	
    # Remove file more older than 7 days
    for files in `find $BACKUP_DIR -mtime +7`; do
    rm -rf ${files}
    done

    # Remove logs more older than 7 days
    for logs in `find $LOGDIR -mtime +7`; do
    rm -rf ${logs}
    done
	
	# Remove logs more older than 30 days from Redis
	find /var/redis/$REDIS_PORT/*.log -type f -mtime +30 -delete
	
    exit 0
fi