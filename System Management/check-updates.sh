#! /bin/sh
set -x

UPDATES=$(yum check-update --quiet)
SECURITY_UPDATES=$(yum --security check-update --quiet)
LOGDIR="/var/log/updates"
LOG="$LOGDIR/updates-`date +"%d%m%Y-%H%M%S"`.log"

[ -d $LOGDIR ] || mkdir $LOGDIR

echo "==============================================================" > $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) - "General updates available:" >> $LOG 2>&1
echo "$UPDATES" >> $LOG 2>&1
echo "" >> $LOG 2>&1
echo "==============================================================" >> $LOG 2>&1
echo $(date +%d.%m.%Y\ %R:%S\ ) - "List of security updates available:" >> $LOG 2>&1
echo "$SECURITY_UPDATES" >> $LOG 2>&1
echo "" >> $LOG 2>&1
mail -s "Updates for $(hostname)" contato@ricardomartins.com.br < $LOG

for logs in `find $LOGDIR -mtime +7`; do
rm -rf ${logs}
done