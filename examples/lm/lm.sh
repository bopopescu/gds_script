#!/bin/bash
#set -x 
SUDOID="computer3 computer4 computer5 computer6 computer7 computer8 computer9"
   for SYSUSER in `echo $SUDOID`
   do
   if  [ ! -z "$SYSUSER" ]
   then 
        echo "SCP sudoes to $SYSUSER,please waiting..." 
        /usr/bin/scp -rp  computer2:/etc/security/limits.conf $SYSUSER:/etc/security/limits.conf
        /usr/bin/scp -rp  computer2:/etc/profile $SYSUSER:/etc/profile
        echo "cp sudoes to $SYSUSER have finished"
        echo ""
        echo ""
    fi
    done
