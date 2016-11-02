#!/bin/bash

resultDir=$1
fileLabel=$2

dStr=`date +%y%m%d`
tStr=`date +%H%M%S`

#HOSTS="c3m3n01 c3m3n02 c3m3n03 c3m3n04"
HOSTS="power1 power2 power4"
for host in $HOSTS
do
	echo "ssh $host cd ${resultDir}/;nmon -F nmon_${fileLabel}_${dStr}-${tStr} -s 5 -c 8000"
        ssh $host "cd ${resultDir}/;nmon -F nmon_${fileLabel}_${dStr}-${tStr} -s 5 -c 8000"
	echo  "ssh $host date > ${resultDir}/iostat_${fileLabel}_${host}_${dStr}-${tStr}.log; iostat -x 5 2>&1 >> ${resultDir}/iostat_${fileLabel}_${host}_${dStr}-${tStr}.log"
	ssh $host "date > ${resultDir}/iostat_${fileLabel}_${host}_${dStr}-${tStr}.log; iostat -x 5 2>&1 >> ${resultDir}/iostat_${fileLabel}_${host}_${dStr}-${tStr}.log" &
done
