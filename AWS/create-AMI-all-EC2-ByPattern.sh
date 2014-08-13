#!/bin/bash

rm -rf output*.txt

ec2-describe-instances --filter tag:Name="INSTANCE-PATTERN*" --filter "instance-state-name=running" > output.txt
sed -e '/^INSTANCE/d' -e '/^BLOCK/d' -e '/^RESERVATION/d' output.txt > output2.txt
sed '/Description/d' ./output2.txt > output3.txt
sed '/Project/d' ./output3.txt > output4.txt
sed '/PDAMWEB004/d' ./output4.txt > output5.txt
awk '{ print $3,$5 }' output5.txt > output6.txt
awk -v date="$(date +"%Y-%m-%d")" '{print $1,"--name",$2,"-",date,"--no-reboot"}' output6.txt | gawk '{print $1,$2,$3 $4 $5,$6 $7}' > output7.txt
awk '{ print $1,$3 }' output7.txt

cat output7.txt | xargs -L1 ec2-create-image