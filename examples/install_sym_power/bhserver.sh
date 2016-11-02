#!/bin/bash
###
CLUSTERNAME=sym71GP
export CLUSTERNAME
BASEPORT=4000
export BASEPORT
CLUSTERADMIN=root
export CLUSTERADMIN
SIMPLIFIEDWEM=N

export SIMPLIFIEDWEM
JAVA_HOME=/opt/jdk

export JAVA_HOME
HADOOP_HOME=/opt/hadoop

export HADOOP_HOME
HADOOP_VERSION=2_4_x

export HADOOP_VERSION
DERBY_DB_HOST=soldev3

export DERBY_DB_HOST
DFS_GUI_HOSTNAME=soldev3
export DFS_GUI_HOSTNAME

DFS_GUI_PORT=5000
export DFS_GUI_PORT

HADOOP_YARN_HOME=/opt/hadoop/
export HADOOP_YARN_HOME

_LICENSE_PATH="$_PACKAGE_PATH/platform_sym_adv_entitlement.dat"
_INSTALL_PATH="$_PACKAGE_PATH/symSetup6.1.0_lnx26-lib25-ppc64.bin"
######################################################
echo "The start installation symphony of master......"
$_INSTALL_PATH --prefix $_INSTALL_HOME --dbpath $_INSTALL_HOME/DB --quiet

source $HOME/profile.platform
egoconfig join '$_MASTER' -f

source $_INSTALL_HOME/profile.platform
egoconfig setentitlement $_LICENSE_PATH 
egosh ego start -f
egosh resource list 
