#!/bin/bash
yum install rsh.x86_64 rsh-server.x86_64 telnet.x86_64 telnet-server.x86_64
#/etc/init.d/xinetd restart

for xinetd in rlogin rsh rexec telnet
        do
        sed 's/yes/no/g' /etc/xinetd.d/$xinetd > /etc/xinetd.d/r2 && mv /etc/xinetd.d/r2 /etc/xinetd.d/$xinetd
        done
for chkconfig in   portmap  nfs ypbind autofs  xinetd
        do
        chkconfig $chkconfig on
        service $chkconfig  restart  > /dev/null
        done
echo "set chkconfig  ok"

echo telnet >> /etc/securetty
echo rlogin >> /etc/securetty
echo rsh >> /etc/securetty
echo rexec >> /etc/securetty
echo "set securetty ok"
/etc/init.d/xinetd restart

echo -n "all set ok,need Re-login os,y  or  n:"
read command
if [ "$command" = "y" ]; then
        killall login
else
        echo "goodbye"
fi

