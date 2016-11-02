#!/bin/bash
#Used to auto fdisk and format disk
#Write by junlee
#2010-04-23

PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH
i=1
while [ $i -lt 7 ]
do
                j=`echo $i|awk '{printf "%c",97+$i}'`
                fdisk /dev/sd$j <<End
n
p
1


w
End
                mkfs.ext4    /dev/sd${j}1
                let i+=1
done
