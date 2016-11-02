#!/bin/bash
set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH
i=1
yum install  btrfs-progs.x86_64
while [ $i -lt 7 ]
do
     j=`echo $i|awk '{printf "%c",97+$i}'`
     mkfs.btrfs    /dev/sd${j}3
     let i+=1
done
mkdir  /com5
mount -t btrfs  /dev/sdb3 /com5
btrfs-vol -a /dev/sdc3   /com5
btrfs-vol -a /dev/sdd3   /com5
btrfs-vol -a /dev/sde3   /com5
btrfs-vol -a /dev/sdf3   /com5
btrfs-vol -a /dev/sdg3   /com5
