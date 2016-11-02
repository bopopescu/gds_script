#!/bin/bash

INSTALL_PACKAGE=/tools/gpfs510
yum -y  install ksh
yum -y install kernel-devel.x86_64
yum -y install cpp.x86_64 libmcpp.x86_64
yum -y install cpp.x86_64 libmcpp.x86_64
yum -y install gcc.x86_64 gcc-c++.x86_64
rpm -ivh  $INSTALL_PACKAGE/gpfs.base-3.5.0-0.x86_64.rpm
rpm -ivh  $INSTALL_PACKAGE/gpfs.gpl-3.5.0-7.noarch.rpm
rpm -ivh  $INSTALL_PACKAGE/gpfs.msg.en_US-3.5.0-7.noarch.rpm
rpm -ivh  $INSTALL_PACKAGE/gpfs.docs-3.5.0-7.noarch.rpm
rpm -Uvh  $INSTALL_PACKAGE/gpfs.base-3.5.0-10.x86_64.update.rpm
rpm -Uvh  $INSTALL_PACKAGE/gpfs.gpl-3.5.0-10.noarch.rpm
rpm -Uvh  $INSTALL_PACKAGE/gpfs.msg.en_US-3.5.0-10.noarch.rpm
rpm -Uvh  $INSTALL_PACKAGE/gpfs.gpl-3.5.0-10.noarch.rpm
rpm -Uvh  $INSTALL_PACKAGE/gpfs.docs-3.5.0-10.noarch.rpm
cd /usr/lpp/mmfs/
make Autoconfig
make World
make InstallImages

