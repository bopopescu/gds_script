#!/bin/bash

#zfs list  | grep data/export/home/ | grep -v data/export/home/exusers \

cat zfslist.txt  | grep data/ | grep -v data/export/home/exusers \
        | awk '{print $1}' | while read zfs_dev
        do
                USER=`echo $zfs_dev | sed 's/data\/home\///g'`
                echo "zfs set -r  sharenfs=rw=@172:@9,root=@172:@9 $zfs_dev"
        done

