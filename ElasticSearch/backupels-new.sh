#!/bin/bash
set -x
ES="http://localhost:9200"
LOCATION="/mnt/backup"
S3DESTINATION="s3://backups-pd/ElasticSearch_PDAMELS002/"
LOGDIR="/var/log/backup"
LOG="$LOGDIR/backupels-`date +"%d%m%Y-%H%M%S"`.log"

# Create directories /mnt/backup e /var/log/backup if didnt exists

if [[ ! -e $LOCATION ]]; then
            mkdir $LOCATION
fi

if [[ ! -e $LOGDIR ]]; then
            mkdir $LOGDIR
fi

/bin/chown -R elasticsearch:elasticsearch $LOCATION

echo "==============================================================" > $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Acertadas as permissÃµes de $LOCATION" >> $LOG 2>&1

# create repository
REPO="$(curl -sS -XGET "$ES/_snapshot/_all")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Status do Repositorio: \n\n$REPO\n" >> $LOG 2>&1
if ! [[ $REPO == *'"location":"'$LOCATION'"'* ]];
then
        echo $(date +%d.%m.%Y\ %R:%S\ ) "O location do repositÃ³rio estÃ¡ diferente do definido na variÃ¡vel LOCATION, criando conforme definido na variÃ¡vel ($LOCATION)" >> $LOG 2>&1
        REPO="$(curl -sS -XPUT "$ES/_snapshot/backup" -d '{ "type": "fs", "settings": { "location": "'$LOCATION'", "compress": true } }')"  >> $LOG 2>&1
        echo $(date +%d.%m.%Y\ %R:%S\ ) "RepositÃ³rio criado!" >> $LOG 2>&1
        if ! [[ $REPO == *'"acknowledged":true'* ]]  >> $LOG 2>&1
        then
         echo $(date +%d.%m.%Y\ %R:%S\ ) "Falha na criaÃ§Ã£o do repositÃ³rio" >> $LOG 2>&1 >> $LOG 2>&1
        fi   >> $LOG 2>&1
fi  >> $LOG 2>&1

# create snapshot
DATE="$(date +"%d%m%Y-%H%M%S")"  >> $LOG 2>&1
BACKINGUP="$(/usr/bin/curl -sS -XPUT "$ES/_snapshot/backup/$DATE?wait_for_completion=true")" >> $LOG 2>&1
BACKUPSTATUS="$(/usr/bin/curl -XGET "$ES/_snapshot/backup/$DATE/_status")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Criando o backup:\n\n$BACKINGUP\n" >> $LOG 2>&1
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Backup status: \n\n$BACKUPSTATUS\n" >> $LOG 2>&1

# compacting files
cd $LOCATION
/bin/tar -czvf backupels-$DATE.tar.gz indices index metadata-$DATE snapshot-$DATE
/bin/rm -rf indices index metadata-$DATE snapshot-$DATE

# sync to s3
cd $LOCATION
/usr/bin/s3cmd --config=/root/.s3cfg put "backupels-$DATE.tar.gz" $S3DESTINATION --progress -v && mv "backupels-$DATE.tar.gz"{,.DONE}  >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Envio do arquivo de backup para o S3 realizado com sucesso!" >> $LOG 2>&1

# removing old log files

for logs in `find $LOGDIR -mtime +7`; do
rm -rf ${logs}
done

echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos arquivos de log com mais de 7 dias contidos em $LOGDIR" >> $LOG 2>&1


# removing old backup files

for backups in `find $LOCATION -mtime +7`; do
rm -rf ${backups}
done

echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos arquivos de backup com mais de 7 dias contidos em $LOCATION" >> $LOG 2>&1
echo "==============================================================" >> $LOG 2>&1


mail -s "** Backup Report of ElasticSearch on SERVER **" contato@ricardomartins.com.br < $LOG