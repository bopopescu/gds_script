#!/bin/bash

for xinetd in rlogin rsh rexec telnet
                        do
                        sed 's/yes/no/g' /etc/xinetd.d/$xinetd > /etc/xinetd.d/r2 && mv /etc/xinetd.d/r2 /etc/xinetd.d/$xinetd
                        done
                        for chkconfig in   portmap  nfs  autofs  xinetd
                        do
                        chkconfig $chkconfig on
                        service $chkconfig  restart  > /dev/null
                        done
                        echo "############ set chkconfig  ok ############"
                        echo telnet >> /etc/securetty
                        echo rlogin >> /etc/securetty
                        echo rsh >> /etc/securetty
                        echo rexec >> /etc/securetty

