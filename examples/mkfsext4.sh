#!/bin/bash
#set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH
i=1
while [ $i -lt 7 ]
do
     j=`echo $i|awk '{printf "%c",97+$i}'`
     mkfs.ext4    /dev/sd${j}1
     let i+=1
done
