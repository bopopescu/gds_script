#!/bin/bash

TOPDIR=`pwd`

#Step 1: 安装依赖
yum -y install ruby apr-devel rrdtool*  libconfuse* expat* pcre* php-gd php-pear php-xml httpd php rsync subversion
if [ $? -ne 0 ]; then
        exit 128
fi


#Step 2: 编译安装
GWEB_VER=2.2.0
tar xzvf gweb-${GWEB_VER}.tar.gz
cd gweb-${GWEB_VER}
make install

cd $TOPDIR
GANGLIA_HOME=/opt/ganglia
GANGLIA_VER=3.3.0
tar xzvf ganglia-${GANGLIA_VER}.tar.gz
cd ganglia-${GANGLIA_VER}
./configure --prefix=${GANGLIA_HOME} --with-gmetad
make
make install
cp -ar gmond/python_modules ${GANGLIA_HOME}/lib64/ganglia/

#Step 3: 启用环境变量
cat > /etc/profile.d/ganglia.sh << EOF
GANGLIA_HOME=${GANGLIA_HOME}
export PATH=\$GANGLIA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$GANGLIA_HOME/lib64:\$GANGLIA_HOME/lib64/ganglia:\$LD_LIBRARY_PATH
export MANPATH=\${GANGLIA_HOME}/man:\$MANPATH
EOF

chmod a+x /etc/profile.d/ganglia.sh
source /etc/profile

#Step 4: 拷贝网页文件至HTTP服务器目录
mkdir -p /var/www/html/ganglia
mkdir -p /var/lib/ganglia/rrds
chown nobody:nobody /var/lib/ganglia/rrds

#3.2.0新增dwoo目录
mkdir -p /var/lib/ganglia/dwoo
chown apache:apache /var/lib/ganglia/dwoo
cp -a web/* /var/www/html/ganglia

#Step 5: 调整启动文件
cp gmetad/gmetad.init /etc/init.d/gmetad
sed -i "s:GMETAD=/usr/sbin/gmetad:GMETAD=${GANGLIA_HOME}/sbin/gmetad:g" /etc/init.d/gmetad
sed -i 's/# chkconfig: 2345 20 80/# chkconfig: 2345 99 5/g' /etc/init.d/gmetad
cp gmond/gmond.init /etc/init.d/gmond
sed -i "s:GMOND=/usr/sbin/gmond:GMOND=${GANGLIA_HOME}/sbin/gmond:g" /etc/init.d/gmond
sed -i 's/# chkconfig: 2345 70 40/# chkconfig: 2345 99 5/g' /etc/init.d/gmond

#将localhost改为管理节点的名称
sed -i "s:data_source \"my cluster\" localhost:data_source \"Cluster\" console:g" ${GANGLIA_HOME}/etc/gmetad.conf
${GANGLIA_HOME}/sbin/gmond -t > ${GANGLIA_HOME}/etc/gmond.conf
#将与gmetad.conf中的配置对应起来
sed -i "s:name = \"unspecified\":name = \"Cluster\":g" ${GANGLIA_HOME}/etc/gmond.conf

#Step 6: 兼容3.1.2中的配置
mkdir -p /etc/ganglia
ln -s ${GANGLIA_HOME}/etc/gmetad.conf /etc/ganglia/gmetad.conf
ln -s ${GANGLIA_HOME}/etc/gmond.conf /etc/ganglia/gmond.conf

#Step 7: 调整路由
if ! grep '/sbin/route add -host 239.2.11.71 dev eth0' /etc/rc.d/rc.local >/dev/null
then
	echo '/sbin/route add -host 239.2.11.71 dev eth0' >> /etc/rc.d/rc.local
fi
/sbin/route add -host 239.2.11.71 dev eth0

if ! grep '/etc/init.d/gmond restart' /etc/rc.d/rc.local >/dev/null
then
	echo '/etc/init.d/gmond restart' >> /etc/rc.d/rc.local
fi

chkconfig gmond on
chkconfig gmetad on
service gmond start
service gmetad start
service httpd start
