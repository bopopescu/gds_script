#!/bin/bash -x
VERSION=1
linux_version() {

if [ -f /etc/issue ] && cat /etc/issue|grep "release 4" > /dev/null
then
        echo "RHEL4"
        #VERSION=rhel4
        #return $VERSION
elif [ -f /etc/redhat-release ] && cat /etc/redhat-release|grep "release 5" > /dev/null
then
        echo "RHEL5"
        #VERSION=rhel5
        #return $VERSION
elif [ -f /etc/redhat-release ] && cat /etc/redhat-release|grep "release 6" > /dev/null
then
        echo "RHEL6"
        #VERSION=rhel6
        #return $VERSION
elif [ -f /sbin/yast2 ]
then
        echo "SUSE"
        #VERSION=suse
        #return $VERSION
elif [ -f /usr/bin/apt-get ]
then
        echo "Ubunut"
else
        echo "other linux"
fi

}

linux_version

