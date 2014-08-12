#!/bin/bash
# v.01 - 12/08/2014
# Ricardo Martins  - contato@ricardomartins.com.br
set -x
source /root/.bashrc
export EC2_HOME='/opt/aws/apitools/ec2'
export EC2_BIN=$EC2_HOME/bin
export PATH=$PATH:$EC2_BIN
export AWS_ELB_HOME=/opt/aws/apitools/elb
export JAVA_HOME=/usr/lib/jvm/jre
SCRIPT_DIR=/root/scripts
FEC2DIN_DIR=/root/scripts
FEC2DIN=$FEC2DIN_DIR/fec2din


cd $SCRIPT_DIR
rm -rf $SCRIPT_DIR/instances*

/usr/bin/python2.6 $FEC2DIN > $SCRIPT_DIR/instances_full
cat $SCRIPT_DIR/instances_full | sed -e '/^AMI/d' -e '/^Type/d' -e '/^Public/d' -e '/^PrivIP/d' -e '/^PubKey/d' -e '/^Days/d' -e '/^AZ/d' -e '/^Disks/d' -e '/^Groups/d' -e '/dev/d' -e '/^Group/d' |  awk '{ if($2) printf("%s ", $2); else print ""; }' > $SCRIPT_DIR/instances
cat $SCRIPT_DIR/instances | awk -v date="$(date +"%d%m%Y")" '{print $1,"--name",$2"_"date,"--no-reboot"}' > $SCRIPT_DIR/ami-input
cat $SCRIPT_DIR/ami-input | xargs -L 1 ec2-create-image