#!/bin/bash

# Delete old logs from xvatransfer_all.sh
# Ricardo Martins - http://www.ricardomartins.com.br
for logs in `find /var/log/backupxen/xvatransfer/ -mtime +7`; do
rm -rf ${logs}
done
