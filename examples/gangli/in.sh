#!/bin/bash

#Step 1: 安装依赖
yum -y install ruby apr-devel expat* pcre*
if [ $? -ne 0 ]; then
        exit 128
fi

GANGLIA_H=power1

#Step 2: 复制文件
GANGLIA_HOME=/opt/ganglia
RRDTOOL_HOME=/opt/rrdtool/
CONFUSE_HOME=/opt/confuse/
mkdir -p ${GANGLIA_HOME} ${RRDTOOL_HOME} ${CONFUSE_HOME}
scp -r ${GANGLIA_H}:${GANGLIA_HOME}/* ${GANGLIA_HOME}
scp -r ${GANGLIA_H}:${RRDTOOL_HOME}/* ${RRDTOOL_HOME}
scp -r ${GANGLIA_H}:${CONFUSE_HOME}/* ${CONFUSE_HOME}
scp ${GANGLIA_H}:/etc/profile.d/ganglia.sh /etc/profile.d/ganglia.sh
scp ${GANGLIA_H}:/etc/ganglia/gmond.conf /etc/ganglia/gmond.conf
scp ${GANGLIA_H}:/etc/init.d/gmond /etc/init.d/gmond
chkconfig gmond on
source /etc/profile

#Step 3: 兼容3.1.2中的配置
mkdir -p /etc/ganglia
ln -s ${GANGLIA_HOME}/etc/gmond.conf /etc/ganglia/gmond.conf

#Step 4: 调整路由
if ! grep '/sbin/route add -host 239.2.11.71 dev eth1' /etc/rc.d/rc.local >/dev/null
then
        echo '/sbin/route add -host 239.2.11.71 dev eth1' >> /etc/rc.d/rc.local
fi
/sbin/route add -host 239.2.11.71 dev eth1

if ! grep '/etc/init.d/gmond restart' /etc/rc.d/rc.local >/dev/null
then
        echo '/etc/init.d/gmond restart' >> /etc/rc.d/rc.local
fi

service gmond start

