#!/bin/bash
##2013/07/31 by GuoLiangWang##
echo "To set environment variables" 
_USERID=502
_GROUPID=502
_USERS=sym61
_GROUP=sym61
_BASEPORT=18555
_MASTER=vpower1
_INSTALL_HOME="/home/sym61"
JAVA_HOME="/opt/ibm/java-ppc64-60/bin"
_PACKAGE_PATH="/users/tools/symphony/sym6.1.0.1_ppc"
_LICENSE_PATH="$_PACKAGE_PATH/platform_sym_adv_entitlement.dat"
_INSTALL_PATH="$_PACKAGE_PATH/symSetup6.1.0_lnx26-lib25-ppc64.bin"
######################################################
echo "The start set up of symphony env......"
export $JAVA_HOME
export CLUSTERADMIN=$_USERS
export CLUSTERNAME=$_USERS
export BASEPORT=$_BASEPORT
export SIMPLIFIEDWEM=N
export DERBY_DB_HOST=$_MASTER
echo "The create a users&group of symphony env......"
groupadd -g $_GROUPID $_GROUP
useradd -u $_USERID -g $_GROUP  $_USERS -d $_INSTALL_HOME
chown -R $_USERID:$_GROUPID $_INSTALL_HOME

echo "The start installation symphony of master......"
$_INSTALL_PATH --prefix $_INSTALL_HOME --dbpath $_INSTALL_HOME/DB --quiet

su - sym61 -c '
source $HOME/profile.platform
egoconfig join '$_MASTER' -f
'
source $_INSTALL_HOME/profile.platform
egosh ego start -f
echo "The symphony install finished"
egosh resource list 

#1 scp packages to /sym
#2 change hostname to computer*
#3 useradd -d /sym/sym61 sym61
#4 install source env.sh & run symcomSetup6.1.0_lnx26-lib23-x64.bin --prefix /sym/sym61 --dbpath /sym/sym61/DB --quiet
#5 su - sym61 & source /sym/sym61/profile.platform & egoconfig join master1 -f
#6 login as root: source profile.platform & run egosh ego start
#7 check if installed successfully:  egosh resource list &  egosh service list
#8 monitor if installed successfully: watch -n 1 egosh resource list
