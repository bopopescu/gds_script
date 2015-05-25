Add to ldap
1:
[root@itwebbak ~]# cat /etc/openldap/ldap.conf
URI ldap://9.111.143.115/
BASE dc=platformlab,dc=ibm,dc=com
TLS_CACERTDIR /etc/openldap/cacerts
URI ldap://9.111.143.116
2:
[root@itwebbak ~]# cat /etc/nsswitch.conf |grep ldap
passwd:     files ldap
shadow:     files ldap
group:      files ldap
netgroup:   files nis ldap
automount:  files nis ldap
3:
[root@itwebbak ~]# cat /etc/sysconfig/authconfig |grep LDAP
USELDAPAUTH=yes
USELDAP=yes
4:
[root@itwebbak gds_scripts]# cat /etc/pam.d/system-auth |grep ldap
auth        sufficient    pam_ldap.so use_first_pass
account     [default=bad success=ok user_unknown=ignore] pam_ldap.so
password    sufficient    pam_ldap.so use_authtok
session     optional      pam_ldap.so

Useful Commands
ldapsearch -x -b "dc=platformlab,dc=ibm,dc=com"

