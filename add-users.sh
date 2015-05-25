#!/bin/bash
for i in `awk '{print $1}' users.list`
do
useradd $i
grep "<$i>" users.list | awk '{print $2}' | passwd --stdin $i
done;

#or
#for i in `seq 1 9`;do useradd user$i;echo "123456" |passwd --stdin user$i;done
