#!/bin/bash

# Apagar logs antigos do script de envio dos xva's para o S3
# Ricardo Martins - http://www.ricardomartins.com.br
for logs in `find /var/log/backupxen/xvatransfer/ -mtime +7`; do
rm -rf ${logs}
done
