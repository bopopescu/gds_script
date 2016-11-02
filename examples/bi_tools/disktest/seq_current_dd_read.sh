#!/bin/bash



# usage: array_io_seq_read.sh thread_num
# $1 - thread_num
hostName=`hostname`
resultFile=part_io_seq_read_direct_${hostName}.result

countSize=10000
bsSize=8k
#bsSize=2048
resultFile=part_io_seq_read_current_direct_bs-${bsSize}-count-${countSize}_${hostName}.result
#diskList="/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh"
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
	cmd[$index]="dd if=${diskPartition} of=/dev/null bs=${bsSize} count=${countSize} iflag=direct"
	cmdParittions[$index]="$partition"
	((index++))
done

#set -x
echo "Begin to execute dd read currently..."
startTime=`date +%s`
#for cmdstr in ${cmd[@]}; # don't work because of space in each string
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
#set +x
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

echo "Total Time for Direct Read: $elapseTime seconds"
echo "Average Direct Read Speed: $averageSpeed bytes/s"
echo "The block size is: $bsSize"
echo "The count size is: $countSize"
