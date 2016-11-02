#!/bin/bash
set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH
i=1
#yum install  btrfs-progs.x86_64
while [ $i -lt 7 ]
do
     j=`echo $i|awk '{printf "%c",97+$i}'`
     mkfs.btrfs    /dev/sd${j}1
     let i+=1
done
#mkdir  /sym
mount -t btrfs  /dev/sdb1 /snap7
btrfs-vol -a /dev/sdc1   /snap7
btrfs-vol -a /dev/sdd1   /snap7
btrfs-vol -a /dev/sde1   /snap7
btrfs-vol -a /dev/sdf1   /snap7
btrfs-vol -a /dev/sdg1   /snap7
