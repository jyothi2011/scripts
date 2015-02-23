#!/bin/bash
source /home/ec2-user/.bashrc

/opt/aws/bin/ec2-describe-instances --filter tag:Name="[instancename]" | /bin/sed -e '/^INSTANCE/d' -e '/^BLOCK/d' -e '/^RESERVATION/d' -e '/Description/d' | /usr/bin/gawk '{ print $3,$5 }' | /usr/bin/tail -1 | /usr/bin/gawk -v date="$(date +"%d-%m-%Y")" '{print $1,"--name",$2,"-",date,"--no-reboot"}' | /usr/bin/gawk '{print $1,$2,$3 $4 $5,$6 $7}' | /usr/bin/xargs -L 1 ec2-create-image
/opt/aws/bin/ec2-describe-images --owner [account-id] | /bin/grep [instancename]-$(date --date='3 days ago' '+%d-%m-%Y') | /usr/bin/gawk '{print $2}' | /usr/bin/xargs -L 1 ec2-deregister
