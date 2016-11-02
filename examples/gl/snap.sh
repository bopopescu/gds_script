#!/bin/bash 

SNAPSHOT_KVM_IMAGES=/kvm_sn
HOSTNAME=`hostname`
TODAY=`date +%Y%m%d_%T`
PATH=/var/lib/libvirt/images
`/usr/bin/qemu-img   convert   -f  raw -O qcow2  "$PATH/v4com1.img"  "$SNAPSHOT_KVM_IMAGES/v4com1$TODAY.img"`
`/usr/bin/qemu-img  snapshot -c  "$SNAPSHOT_KVM_IMAGES/v4com1$TODAY.img" "$SNAPSHOT_KVM_IMAGES/v4com1com$TODAY.img"` 
