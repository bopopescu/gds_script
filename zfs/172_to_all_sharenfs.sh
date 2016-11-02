#!/bin/bash

#zfs list  | grep data/export/home/ | grep -v data/export/home/exusers \

cat zfslist.txt  | grep data/export/ | grep -v data/export/home/exusers \
        | awk '{print $1}' | while read zfs_dev
        do
                USER=`echo $zfs_dev | sed 's/data\/home\///g'`
                echo "zfs set -r  sharenfs=rw,root=@9:@172 $zfs_dev"
        done

