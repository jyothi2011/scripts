#!/bin/bash

# Script para envio de imagens xva do Xen para um Bucket no S3
# Este script pega todos os arquivos da pasta /mnt/backup, envia para o S3, e depois remove localmente. 
# Apos o envio, adiciona a extensao .DONE no arquivo para controle de erros no caso de falha no upload. Desta forma, nao apaga arquivos que nao tenham sido enviados ainda.
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

