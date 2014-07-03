#!/bin/bash
# Script that creates snapshot, export the xva file and upload it to S3.
# The machine is specified by UUID in VMUUID variable.
# Ricardo Martins - http://www.ricardomartins.com.br

set -x
VMNAME=ServerName
VMUUID=1b308138-96c4-2637-30e5-d4f0180205f8
EXPORTPATH=/mnt/backup
DATE=`date +%d%m%Y`
LOGDIR=/var/log/backupxen/snapshot
LOG=$LOGDIR/snapshot-$VMNAME-`date +"%d%m%Y-%H%M%S"`.log
XVADIR=/mnt/backup
S3DESTINATION=s3://xenbackup

echo "==============================================================" > $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "UUID $VMUUID encontrado com nome de: $VMNAME" >> $LOG 2>&1

# create snapshot
echo $(date +%d.%m.%Y\ %R:%S\ ) "Criando snapshot: \"$VMNAME\" " >> $LOG 2>&1
SNAPSHOTUUID=$(xe vm-snapshot uuid=$VMUUID new-name-label="$VMNAME") >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Snapshot UUID: $SNAPSHOTUUID" >> $LOG 2>&1

# convert snapshot to vm
echo $(date +%d.%m.%Y\ %R:%S\ ) "Convertendo snapshot em VM" >> $LOG 2>&1
xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPSHOTUUID >> $LOG 2>&1

# export snapshot-vm to file
echo $(date +%d.%m.%Y\ %R:%S\ ) "Exportando para o arquivo: $EXPORTPATH/$DATE-$VMNAME.xva" >> $LOG 2>&1
xe vm-export vm=$SNAPSHOTUUID filename="$EXPORTPATH/$DATE-$VMNAME.xva" >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) "Export finalizado." >> $LOG 2>&1

# delete snapshot
echo $(date +%d.%m.%Y\ %R:%S\ ) "Deletando snapshot.." >> $LOG 2>&1
xe vm-uninstall uuid=$SNAPSHOTUUID force=true >> $LOG 2>&1

echo $(date +%d.%m.%Y\ %R:%S\ ) "Concluída a criação do arquivo XVA com sucesso!" >> $LOG 2>&1

echo $(date +%d.%m.%Y\ %R:%S\ ) "Iniciando a transferência para o S3..." >> $LOG 2>&1
cd $XVADIR >> $LOG 2>&1
/usr/bin/s3cmd --config=/root/.s3cfg put $XVADIR/$DATE-$VMNAME.xva $S3DESTINATION --progress -v && mv $DATE-$VMNAME.xva{,.DONE}  >> $LOG 2>&1
rm $DATE-$VMNAME.xva.DONE  >> $LOG 2>&1
echo  $(date +%d.%m.%Y\ %R:%S\ ) "Envio para o S3 concluído com sucesso, processo finalizado." >> $LOG 2>&1
echo "==============================================================" >> $LOG 2>&1
mail -s "** Backup Report of \"$VMNAME\" **" monitor@dominio.com < $LOG
