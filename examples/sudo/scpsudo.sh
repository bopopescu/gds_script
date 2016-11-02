#!/bin/bash
#set -x 
SUDOID="master0 computer2 computer3 computer4 computer5 computer6 computer7 computer8 computer9 pmaster0 pmaster1 power1 power2 power3 power4"
   for SYSUSER in `echo $SUDOID`
   do
   if  [ ! -z "$SYSUSER" ]
   then 
        echo "SCP sudoes to $SYSUSER,please waiting..." 
        /usr/bin/scp -rp  /etc/sudoers $SYSUSER:/etc/
        echo "cp sudoes to $SYSUSER have finished"
        echo ""
        echo ""
    fi
    done
