#!/bin/bash

#zfs list  | grep data/export/home/ | grep -v data/export/home/exusers \

cat ./zfslist_cnbjfs07.txt  | grep data/export/home/ | grep -v data/export/home/exusers \
	| awk '{print $1}' | while read zfs_dev
	do
		USER=`echo $zfs_dev | sed 's/data\/export\/home\///g'`
		echo "old_$USER       -intr,noacl,hard,rsize=8192,wsize=8192,timeo=1000       cnbjfs07:/data/export/home/$USER"
	done
