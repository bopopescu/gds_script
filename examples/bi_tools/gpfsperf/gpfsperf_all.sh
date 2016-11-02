#!/bin/bash
# $0 <result dir> <fs blocksize> <recordSizeList> <io flags>
# e.g $0 8M "8M 2M 1M" will run with cache io
#     $0 8M "512" -dio will run with dio
set -x
#fs="sncfs"
fs="lcfs"
((pagepool=32*1024*1024*1024))
resultDir=$1
fsBlockSize=$2
recordSizeList="$3"
ioFlags="$4"
th=$5
IOLabel="_cacheIO"
runseconds=240
#hostList="c3m3n01 c3m3n02 c3m3n03 c3m3n04"
hostList="power1 power2 power4"
if [[ $# -lt 2 ]];
then
	echo "$0 <result dir> <fs blocksize> <recordSizeList> [io flags] <thread>"
	exit 1
fi
((fileSize=2*pagepool))
if [[ "$ioFlags" != "" ]];
then
	echo "$ioFlags" | grep dio 2>&1 > /dev/null
	if [[ $? -eq 0 ]];
	then
		((fileSize=100*1024*1024))
		#ioFlags="-$ioFlags"
		IOLabel="_DIO"
	fi
fi
for recordSize in $recordSizeList
do
	for accessPatten in seq rand
	do
		for operation in create write read
		do
		#	/home/zhengyzy/bi_tools/tools_BI_0713/gpfsperf/perf_mon.sh ${resultDir} ${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}
			/lcfs/bi_tools/gpfsperf/perf_mon.sh ${resultDir} ${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}
			if [[ "$operation" == "read" || "$operation" == "write" ]];
			then
				date
				for host in $hostList
				do
					/usr/lpp/mmfs/bin/mmdsh -N all '/usr/lpp/mmfs/bin/mmfsadm resetstats'
					# for read, we need to write the file first. So, use the file created in write mode
					echo "$host@/opt/bi_tools/gpfsperf/gpfsperf $operation $accessPatten /$fs/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_create_${IOLabel}_${host} -r $recordSize -n $fileSize $ioFlags -th ${th} -runtime ${runseconds}"
					ssh $host "/opt/bi_tools/gpfsperf/gpfsperf $operation $accessPatten /$fs/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_create_${IOLabel}_${host} -r $recordSize -n $fileSize $ioFlags -th ${th} -runtime ${runseconds} 2>&1 | tee ${resultDir}/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}.${host}.result" &
				done
			else
				for host in $hostList
				do
					/usr/lpp/mmfs/bin/mmdsh -N all '/usr/lpp/mmfs/bin/mmfsadm resetstats'
					echo "${host}@/opt/bi_tools/gpfsperf/gpfsperf $operation $accessPatten /$fs/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}_${host} -r $recordSize -n $fileSize $ioFlags -th ${th}" 
					ssh $host "/opt/bi_tools/gpfsperf/gpfsperf $operation $accessPatten /$fs/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}_${host} -r $recordSize -n $fileSize $ioFlags -th ${th} 2>&1 | tee ${resultDir}/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}.${host}.result" &
				done
			fi
			wait
			date
			for host in $hostList
			do
				ssh $host "/usr/lpp/mmfs/bin/mmfsadm dump all > ${resultDir}/internaldump_${fsBlockSize}_${recordSize}_${accessPatten}_${operation}_${IOLabel}.${host}"
			done
			# kill all nmon and iostat
			for host in $hostList
			do
        			for pid in `ssh $host  "ps -efl | grep nmon" | awk '{print \$4}'`
        			do
                			ssh $host "kill -9 $pid"
        			done

        			for pid in `ssh $host  "ps -efl | grep iostat" | awk '{print \$4}'`
        			do
                			ssh $host "kill -9 $pid"
        			done
			done
		done
		rm -fr /$fs/gpfsperf_${fsBlockSize}_${recordSize}_${accessPatten}_create_${IOLabel}_*
	done
done
