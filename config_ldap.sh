#!/bin/bash
echo -n "enter your login ID:"
read LOGINID
#######################################################
echo "9.111.143.115              bj1ldap1.platformlab.ibm.com bj1ldap1"  >> /etc/hosts
echo "9.111.143.116              bj1ldap2.platformlab.ibm.com bj1ldap2"  >> /etc/hosts
echo "9.111.143.111              bj1is1.platformlab.ibm.com bj1ldap2"  >> /etc/hosts
echo "9.111.143.112              bj1is2.platformlab.ibm.com bj1ldap2"  >> /etc/hosts
echo "search eng.platformlab.ibm.com" > /etc/resolv.conf
echo "nameserver 9.111.143.111" >> /etc/resolv.conf
echo "nameserver 9.111.143.112" >> /etc/resolv.conf
echo "set hostname ok"
#######################################################
#set /etc/ldap.conf
/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=9.111.143.115 --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
#echo "base dc=platformlab,dc=ibm,dc=com" > /etc/ldap.conf
#echo "uri ldap://9.111.143.115" >> /etc/ldap.conf
echo "uri ldap://9.111.143.116" >> /etc/ldap.conf
#echo "URI ldap://9.111.143.115" > /etc/openldap/ldap.conf
echo "URI ldap://9.111.143.116" >> /etc/openldap/ldap.conf
#echo "BASE dc=platformlab,dc=ibm,dc=com" >> /etc/openldap/ldap.conf
#echo "TLS_CACERTDIR /etc/openldap/cacerts" >> /etc/openldap/ldap.conf
echo "set ldap client ok"
#######################################################
echo "ALL     ALL=(ALL)       NOPASSWD: ALL"  >> /etc/sudoers
echo "set sudo ok"
#######################################################
echo telnet >> /etc/securetty
echo rlogin >> /etc/securetty
echo rsh >> /etc/securetty
echo rexec >> /etc/securetty
echo "set securetty ok"
#######################################################
for xinetd in rlogin rsh rexec telnet
        do
        sed 's/yes/no/g' /etc/xinetd.d/$xinetd > /etc/xinetd.d/r2 && mv /etc/xinetd.d/r2 /etc/xinetd.d/$xinetd
        done
for chkconfig in  nfs  autofs  xinetd
        do
        chkconfig $chkconfig on
        service $chkconfig  restart  > /dev/null
        done
echo "set chkconfig  ok"
#######################################################
#set auto.misc
echo "cd              -fstype=iso9660,ro,nosuid,nodev :/dev/cdrom" > /etc/auto.misc
echo "$LOGINID          -rw,soft,intr           172.20.192.98:/data/export/home/$LOGINID" >> /etc/auto.misc
echo "scratch_qa          -rw,soft,intr           172.20.192.86:/data/export/scratch_qa" >> /etc/auto.misc
echo "scratch_dev          -rw,soft,intr           172.20.192.86:/data/export/scratch_dev" >> /etc/auto.misc
echo "scratch_dev          -rw,soft,intr           172.20.192.86:/data/export/scratch_dev" >> /etc/auto.misc
echo "pcc_qa          -rw,soft,intr           172.20.192.86:/data/export/pcc_qa" >> /etc/auto.misc
echo "pcc_dev          -rw,soft,intr           172.20.192.86:/data/export/pcc_dev" >> /etc/auto.misc
echo "set auto.misc ok"
#######################################################
# set auto.master
echo "/home   /etc/auto.misc  --timeout=60" >> /etc/auto.master
echo "/scratch   /etc/auto.misc  --timeout=60" >> /etc/auto.master
echo "/pcc   /etc/auto.misc  --timeout=60" >> /etc/auto.master
echo "set auto.master ok"
#######################################################
# restart autofs
service autofs restart >> /dev/null
echo "restart autofs ok"
#######################################################
echo "all set ok,need Re-login os, y or n:"
read command
if [ "$command" = "y" ]; then
        killall login
else
        echo "goodbye"
fi
