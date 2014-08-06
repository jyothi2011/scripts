#!/bin/bash

set -x
export EC2_HOME='/opt/aws/apitools/ec2'
export EC2_BIN=$EC2_HOME/bin
export PATH=$PATH:$EC2_BIN
export AWS_CREDENTIAL_FILE=/root/.ec2/snapshot.cred
export EC2_PRIVATE_KEY=/root/.ec2/snapshot-pkcs8.key
export EC2_CERT=/root/.ec2/snapshot.crt
export AWS_ELB_HOME=/opt/aws/apitools/elb
export JAVA_HOME=/usr/lib/jvm/jre

rm -rf output*.txt

ec2-describe-instances  --filter tag:Name="PDAM*" --filter "instance-state-name=running" > output.txt
sed -e '/^INSTANCE/d' -e '/^BLOCK/d' -e '/^RESERVATION/d' output.txt > output2.txt
sed '/Description/d' ./output2.txt > output3.txt
awk '{ print $3,$5 }' output3.txt > output4.txt
awk -v date="$(date +"%Y-%m-%d")" '{print $1,"--name",$2,"-",date,"--no-reboot"}' output4.txt | gawk '{print $1,$2,$3 $4 $5,$6 $7}' > output5.txt
awk '{ print $1,$3 }' output5.txt

cat output5.txt | xargs -L 1 ec2-create-image
