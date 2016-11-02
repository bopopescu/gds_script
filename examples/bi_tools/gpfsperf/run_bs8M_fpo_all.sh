#!/bin/bash

#fs="sncfs"
fs="lcfs"
label="fpo.tuned_threads"
#DIR=/home/zhengyzy/bi_tools/tools_BI_0713/gpfsperf
DIR=/lcfs/bi_tools/gpfsperf
#hosts="c3m3n01 c3m3n02 c3m3n03 c3m3n04"
hosts="power1 power2 power4"
set -x
for th in 1 64
do
for replica in 3
do
	for host in $hosts
	do
		ssh $host "cd $DIR;mkdir ${label}_bs8M_r${replica}m${replica}.th${th}"
	done
        mmumount $fs -a
        mmdelfs $fs -p
	mmshutdown -a
	mmstartup -a
        mmtracectl --stop
        mmdsh -N all "/usr/lpp/mmfs/bin/mmfsadm trace all 0"

       #cd  /home/zhengyzy/bi_tools/cluster_4nodes_gnr/
	cd  /lcfs/bi_tools/gpfsperf
        ./crfs_1m6d_256K_8M.sh $replica $replica
        mmmount $fs -a
        cd $DIR/${label}_bs8M_r${replica}m${replica}.th${th}
        echo "mmlsconfig..." > gpfs_env.log
        mmlsconfig >> gpfs_env.log
        echo "mmlsfs $fs ..." >> gpfs_env.log
        mmlsfs $fs >> gpfs_env.log
        echo "mmlsdisk $fs -L ..." >> gpfs_env.log
        mmlsdisk $fs -L >> gpfs_env.log
        echo "mmlspool $fs all -L ..." >> gpfs_env.log
        mmlspool $fs all -L >> gpfs_env.log
        echo "ps -elf | grep lxt..." >> gpfs_env.log
        ps -elf | grep lxt >> gpfs_env.log
        for host in $hosts
        do
		echo "ssh $host /usr/lpp/mmfs/bin/mmfsadm showtrace..." >> gpfs_env.log
                ssh $host "/usr/lpp/mmfs/bin/mmfsadm showtrace" >> gpfs_env.log
        done

#	/home/zhengyzy/bi_tools/tools_BI_0713/gpfsperf/gpfsperf_all.sh $DIR/${label}_bs8M_r${replica}m${replica}.th${th}  8M "8M" "" $th
#	/home/zhengyzy/bi_tools/tools_BI_0713/gpfsperf/gpfsperf_all.sh $DIR/${label}_bs8M_r${replica}m${replica}.th${th} 8M "512" "-dio" $th
	/lcfs/bi_tools/gpfsperf/gpfsperf_all.sh $DIR/${label}_bs8M_r${replica}m${replica}.th${th}  8M "8M" "" $th
        /lcfs/bi_tools/gpfsperf/gpfsperf_all.sh $DIR/${label}_bs8M_r${replica}m${replica}.th${th} 8M "512" "-dio" $th
done
done
