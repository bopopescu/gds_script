#!/bin/bash
# usage: array_io_seq_read.sh thread_num
# $1 - thread_num
hostName=`hostname`

countSize=10000
#bsSize=2048
bsSize=256k
resultFile=part_io_seq_write_current_direct+append_bs-${bsSize}-count-${countSize}_${hostName}.result
#diskList="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh"
#diskList="/dev/dm-0 /dev/dm-1 /dev/dm-2"
#power1
diskList="/dev/sdd /dev/sda /dev/sdb"
#power2
#diskList="/dev/sda /dev/sdc /dev/sdd"
#power3
#diskList="/dev/sdc /dev/sdd /dev/sde"

declare -a cmd
declare -a cmdParitions

index=0
for diskPartition in $diskList;
do	
	partition=${diskPartition##*/}
        #if [[ "$hostName" == "hdperf019.svl.ibm.com" || "$hostName" == "hdperf019" ]];
        #then
        #        if [[ "$partition" == "sdl1" ]];
        #        then
        #                continue
        #        fi
        #fi
	echo > ${resultFile}.$partition
	cmd[$index]="dd if=/dev/zero of=${diskPartition} bs=${bsSize} count=${countSize} oflag=direct,append"
	cmdParittions[$index]="$partition"
	((index++))	
done

echo "Begin to execute dd currently..."
startTime=`date +%s`
index=0
count=${#cmd[@]}
while ((index < count)) 
do
	echo "${cmd[$index]}"
	${cmd[$index]}  2>&1 | tee ${resultFile}.${cmdParittions[$index]} &
	((index++))
done

wait
endTime=`date +%s`

elapseTime=0
averageSpeed=0
((elapseTime=endTime-startTime))
if [[ $elapseTime -eq 0 ]];
then
	elapseTime=1
fi
((averageSpeed=countSize*bsSize/elapseTime))

echo
echo "=====================Summary================"
for diskPartition in $diskList;
do
	partition=${diskPartition##*/}
	speed=`cat ${resultFile}.$partition | grep "MB/s" | awk '{print \$8" "\$9}'`
	echo "$partition: $speed"
done
echo 

echo "Total Time for Direct Write: $elapseTime seconds"
echo "Average Direct Write Speed: $averageSpeed bytes/s"
echo "The block size is: $bsSize"
echo "The count size is: $countSize"

