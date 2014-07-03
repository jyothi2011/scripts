#!/bin/bash

# Apagar logs antigos do script de cria��o de snapshots
# Ricardo Martins - http://www.ricardomartins.com.br
for logs in `find /var/log/backupxen/snapshot/ -mtime +7`; do
rm -rf ${logs}
done
