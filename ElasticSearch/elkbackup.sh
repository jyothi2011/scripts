#!/bin/bash
#set -x
ES="http://localhost:9200"
LOCATION="/mnt/backup"
S3DESTINATION="s3://backups-els/"
LOGDIR="/var/log/backup"
LOG="$LOGDIR/backupels-`date +"%d%m%Y-%H%M%S"`.log"

# Criar os diretórios /mnt/backup e /var/log/backup caso não existam primeiro.
/bin/chown -R elasticsearch:elasticsearch $LOCATION

echo "==============================================================" > $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Acertadas as permissões de $LOCATION" >> $LOG 2>&1

# create repository
REPO="$(curl -sS -XGET "$ES/_snapshot/_all")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Status do Repositorio: \n\n$REPO\n" >> $LOG 2>&1
if ! [[ $REPO == *'"location":"'$LOCATION'"'* ]];
then
        echo $(date +%d.%m.%Y\ %R:%S\ ) "O location do repositório está diferente do definido na variável LOCATION, criando conforme definido na variável ($LOCATION)" >> $LOG 2>&1
        REPO="$(curl -sS -XPUT "$ES/_snapshot/backup" -d '{ "type": "fs", "settings": { "location": "'$LOCATION'", "compress": true } }')"  >> $LOG 2>&1
        echo $(date +%d.%m.%Y\ %R:%S\ ) "Repositório criado!" >> $LOG 2>&1
        if ! [[ $REPO == *'"acknowledged":true'* ]]  >> $LOG 2>&1
        then
         echo $(date +%d.%m.%Y\ %R:%S\ ) "Falha na criação do repositório" >> $LOG 2>&1 >> $LOG 2>&1
        fi   >> $LOG 2>&1
fi  >> $LOG 2>&1

# create snaptshot
DATE="$(date +"%d%m%Y-%H%M%S")"  >> $LOG 2>&1
BACKINGUP="$(/usr/bin/curl -sS -XPUT "$ES/_snapshot/backup/$DATE?wait_for_completion=true")" >> $LOG 2>&1
BACKUPSTATUS="$(/usr/bin/curl -XGET "$ES/_snapshot/backup/$DATE/_status")"
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Criando o backup:\n\n$BACKINGUP\n" >> $LOG 2>&1
echo -e $(date +%d.%m.%Y\ %R:%S\ ) "Backup status: \n\n$BACKUPSTATUS\n" >> $LOG 2>&1

# sync to s3
/usr/bin/s3cmd --config=/home/ubuntu/.s3cfg put "index" $S3DESTINATION --progress -v && mv "index"{,.DONE}  >> $LOG 2>&1
/usr/bin/s3cmd --config=/home/ubuntu/.s3cfg put "metadata-$DATE" $S3DESTINATION --progress -v  && mv "metadata-$DATE"{,.DONE} >> $LOG 2>&1
/usr/bin/s3cmd --config=/home/ubuntu/.s3cfg put "snapshot-$DATE" $S3DESTINATION --progress -v  && mv "snapshot-$DATE"{,.DONE} >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Envio dos arquivos index, metadata-$DATE e snapshot-$DATE concluído com sucesso!" >> $LOG 2>&1
/bin/rm -rf *.DONE  >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos os arquivos gerados em $LOCATION" >> $LOG 2>&1


# removing old log files

for logs in `find $LOGDIR -mtime +7`; do
rm -rf ${logs}
done

echo $(date +%d.%m.%Y\ %R:%S\ ) "Removidos arquivos de log com mais de 7 dias contidos em $LOGDIR" >> $LOG 2>&1
echo "==============================================================" >> $LOG 2>&1
