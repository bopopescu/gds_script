#!/bin/bash 

SERVER=9.111.143.101
LDAP1=bj1ldap1.eng.platformlab.ibm.com
LDAP2=bj1ldap2.eng.platform.ibm.com

#Liu Xin Chun platformservice
touch /etc/SYSTEMCONFIGURED
wget -O /etc/init.d/platformservice ftp://labvmserv.eng.platformlab.ibm.com/virtroot/config/scripts/platformservice
chmod +x /etc/init.d/platformservice
chkconfig --add platformservice
/etc/init.d/platformservice start

#wget -O /etc/init.d/platformservice http://9.111.143.101/platformservice
#disable NIS and enable, setup LDAP settings
/usr/sbin/authconfig --disablenis --update > /dev/null
echo "NIS authorization disabled"
#/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=bj1ldap1.eng.platformlab.ibm.com,bj1ldap2.eng.platform.ibm.com --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=bj1ldap1.eng.platformlab.ibm.com --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
echo "LDAP authorization enabled"

#setup auto mount and restart autofs
wget -O /etc/auto.master http://$SERVER/auto.master > /dev/null
wget -O /etc/auto.home http://$SERVER/auto.home > /dev/null
wget -O /etc/auto.pcc http://$SERVER/auto.pcc > /dev/null
wget -O /etc/auto.scratch http://$SERVER/auto.scratch > /dev/null
service autofs restart
echo "Autofs set ok"
