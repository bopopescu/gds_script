#!/bin/sh

yum -y install opensm
/etc/init.d/opensm start
chkconfig opensm on
chkconfig openibd on
yum -y install infiniband-diags
/etc/init.d/rdma start
chkconfig rdma on
service NetworkManager stop
chkconfig NetworkManager off
service network restart
