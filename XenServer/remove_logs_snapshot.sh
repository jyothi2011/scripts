#!/bin/bash

# Delete old logs from snapshot_transfer_s3.sh
# Ricardo Martins - http://www.ricardomartins.com.br
for logs in `find /var/log/backupxen/snapshot/ -mtime +7`; do
rm -rf ${logs}
done
