#!/bin/bash

#Step 1: 安装依赖
yum -y install ruby apr-devel rrdtool*  libconfuse* expat* pcre*
if [ $? -ne 0 ]; then
        exit 128
fi


#Step 2: 复制文件
GANGLIA_HOME=/opt/ganglia
mkdir -p ${GANGLIA_HOME}
scp -r console:${GANGLIA_HOME}/* ${GANGLIA_HOME}
scp console:/etc/profile.d/ganglia.sh /etc/profile.d/ganglia.sh
scp console:/etc/ganglia/gmond.conf /etc/ganglia/gmond.conf
scp console:/etc/init.d/gmond /etc/init.d/gmond
chkconfig gmond on
source /etc/profile

#Step 3: 兼容3.1.2中的配置
mkdir -p /etc/ganglia
ln -s ${GANGLIA_HOME}/etc/gmond.conf /etc/ganglia/gmond.conf

#Step 4: 调整路由
if ! grep '/sbin/route add -host 239.2.11.71 dev eth0' /etc/rc.d/rc.local >/dev/null
then
	echo '/sbin/route add -host 239.2.11.71 dev eth0' >> /etc/rc.d/rc.local
fi
/sbin/route add -host 239.2.11.71 dev eth0

if ! grep '/etc/init.d/gmond restart' /etc/rc.d/rc.local >/dev/null
then
	echo '/etc/init.d/gmond restart' >> /etc/rc.d/rc.local
fi

service gmond start
