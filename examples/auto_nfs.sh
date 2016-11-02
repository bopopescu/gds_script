#!/bin/bash

yum -y autofs-5.0.5-73.el6.ppc64
yum -y nfs*
/etc/init.d/autofs restart
/etc/init.d/nfs  restart
su - wanggl -c 'ls -al'
