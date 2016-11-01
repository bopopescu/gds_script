#!/bin/bash
##2013/07/31 by GuoLiangWang##
echo "To set environment variables"
_USERID=502
_GROUPID=502
_USERS=sym61
_GROUP=sym61
_BASEPORT=18555
_MASTER=`hostname`
_INSTALL_HOME="/home/sym61"
#JAVA_HOME="/usr/lib/jvm/java-1.6.0"
_PACKAGE_PATH="/opt"
######################################################
echo "The start set up of symphony env......"
export JAVA_HOME="/usr/lib/jvm/java-1.6.0"
export CLUSTERADMIN=$_USERS
export CLUSTERNAME=$_USERS
export BASEPORT=$_BASEPORT
export SIMPLIFIEDWEM=N
export DERBY_DB_HOST=$_MASTER
echo "The create a users&group of symphony env......"
groupadd -g $_GROUPID $_GROUP
useradd -u $_USERID -g $_GROUP  $_USERS -d $_INSTALL_HOME
echo "q1w2e3r4" |passwd --stdin sym61
cp -r /root/.ssh /home/sym61/
chown -R $_USERID:$_GROUPID $_INSTALL_HOME
chown -R $_USERID:$_GROUPID $_PACKAGE_PATH
#sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
service sshd start

echo "Install_type:$1"
echo "Default command:$2"
#echo "MasteIP:$3"
echo "Mastername:$3"

if [[ $1 == "M" ]] ; then
IP=`ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
echo "ipaddress=$IP"
echo "The start installation symphony of master......"
_LICENSE_PATH="$_PACKAGE_PATH/platform_sym_adv_entitlement.dat"
_INSTALL_PATH="$_PACKAGE_PATH/symSetup6.1.0_lnx26-lib23-x64.bin"
$_INSTALL_PATH --prefix $_INSTALL_HOME --dbpath $_INSTALL_HOME/DB --quiet

su - sym61 -c '
source /home/sym61/profile.platform
egoconfig join '$_MASTER' -f
'
source $_INSTALL_HOME/profile.platform
egoconfig setentitlement $_LICENSE_PATH
egosh ego start -f
echo "The symphony install finished"

elif [[ $1 == "C" ]]; then
IP=`ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
echo "ipaddress=$IP"
_INSTALL_PATH="$_PACKAGE_PATH/symcompSetup6.1.0_lnx26-lib23-x64.bin"
$_INSTALL_PATH --prefix $_INSTALL_HOME --dbpath $_INSTALL_HOME/DB --quiet
su - sym61 -c '
source /home/sym61/profile.platform
egoconfig join '$3' -f
'
source $_INSTALL_HOME/profile.platform
egosh ego start -f
egosh resource list
fi

if [[ $2 == "D" ]]; then
  /bin/bash
fi
