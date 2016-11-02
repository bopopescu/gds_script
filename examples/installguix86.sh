#!/bin/sh


yum -y install xorg-x11-xdm
yum -y install kdm.ppc64
yum install gnome-*
sed -i '$s/^/!/' /etc/X11/xdm/xdm-config
sed -i '49s/^#//' /etc/X11/xdm/Xaccess
sed -i '$s/^/#/' /etc/X11/xdm/Xservers
sed -i '111s/false/true/' /etc/kde/kdm/kdmrc
kdm
netstat -tlunp|grep 177
