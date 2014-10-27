#!/bin/bash
set -x
ES="http://localhost:9200"
LOCATION="/mnt/backup"
S3DESTINATION="s3://backups-els"
LOGDIR="/var/log/backup"
LOG="$LOGDIR/backupels-`date +"%d%m%Y-%H%M%S"`.log"

# Criar os diretÃ³rios /mnt/backup e /var/log/backup caso nÃ£o exista.
/bin/chown -R elasticsearch:elasticsearch $LOCATION

echo "==============================================================" > $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Acertadas as permissÃµes de $LOCATION" >> $LOG 2>&1

# create repository
REPO="$(curl -sS -XGET "$ES/_snapshot/_all")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Status do Repositorio: \n\n$REPO\n" >> $LOG 2>&1
if ! [[ $REPO == *'"location":"'$LOCATION'"'* ]];
then
        echo $(date +%d.%m.%Y\ %R:%S\ ) "O location do repositÃ³rio estÃ¡ diferente do definido na variÃ¡vel LOCATION, criando conforme definido na variÃ¡vel ($LOCATION)" >> $LOG 2>&1    REPO="$(curl -sS -XPUT "$ES/_snapshot/backup" -d '{ "type": "fs", "settings": { "location": "'$LOCATION'", "compress": true } }')"  >> $LOG 2>&1
        echo $(date +%d.%m.%Y\ %R:%S\ ) "RepositÃ³rio criado!" >> $LOG 2>&1
        if ! [[ $REPO == *'"acknowledged":true'* ]]  >> $LOG 2>&1
        then
         echo $(date +%d.%m.%Y\ %R:%S\ ) "Falha na criaÃ§Ã£o do repositÃ³rio" >> $LOG 2>&1 >> $LOG 2>&1
        fi   >> $LOG 2>&1
fi  >> $LOG 2>&1

# create snaptshot
DATE="$(date +"%d%m%Y-%H%M%S")"  >> $LOG 2>&1
BACKINGUP="$(/usr/bin/curl -sS -XPUT "$ES/_snapshot/backup/$DATE?wait_for_completion=true")" >> $LOG 2>&1
BACKUPSTATUS="$(/usr/bin/curl -XGET "$ES/_snapshot/backup/$DATE/_status")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Criando o backup:\n\n$BACKINGUP\n" >> $LOG 2>&1
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Backup status: \n\n$BACKUPSTATUS\n" >> $LOG 2>&1

# compacting indices
cd $LOCATION
/bin/tar -czvf indices-$DATE.tar.gz indices
/bin/rm -rf indices

# sync to s3
cd $LOCATION
/usr/bin/s3cmd --config=/root/.s3cfg put "index" $S3DESTINATION --progress -v && mv "index"{,.DONE}  >> $LOG 2>&1
/usr/bin/s3cmd --config=/root/.s3cfg put "metadata-$DATE" $S3DESTINATION --progress -v  && mv "metadata-$DATE"{,.DONE} >> $LOG 2>&1
/usr/bin/s3cmd --config=/root/.s3cfg put "snapshot-$DATE" $S3DESTINATION --progress -v  && mv "snapshot-$DATE"{,.DONE} >> $LOG 2>&1
/usr/bin/s3cmd --config=/root/.s3cfg put "indices-$DATE.tar.gz" $S3DESTINATION --progress -v  && mv "indices-$DATE.tar.gz"{,.DONE} >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Envio do diretorio de indices, arquivos index, metadata-$DATE e snapshot-$DATE concluÃ­do com sucesso!" >> $LOG 2>&1
/bin/rm -rf *.DONE  >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos os arquivos gerados em $LOCATION" >> $LOG 2>&1

# removing old log files

for logs in `find $LOGDIR -mtime +7`; do
rm -rf ${logs}
done

echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos arquivos de log com mais de 7 dias contidos em $LOGDIR" >> $LOG 2>&1
echo "==============================================================" >> $LOG 2>&1

mail -s "** Backup Report of ElasticSearch **" contato@ricardomartins.com.br < $LOG