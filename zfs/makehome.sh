#!/bin/bash

#zfs list  | grep data/export/home/ | grep -v data/export/home/exusers \

cat /tmp/zfslist_cnbjfs07.txt  | grep data/export/home/ | grep -v data/export/home/exusers \
	| awk '{print $1}' | while read zfs_dev
	do
		USER=`echo $zfs_dev | sed 's/data\/export\/home\///g'`
		echo "zfs create  -o sharenfs=rw=@172,root=@172 -o quota=3G -o compression=off $zfs_dev; chown $USER /$zfs_dev"
	done
