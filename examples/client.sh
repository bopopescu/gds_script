#!/bin/bash
export CLUSTERADMIN=sym61
export CLUSTERNAME=sym61
export BASEPORT=18555
export SIMPLIFIEDWEM=N
export DERBY_DB_HOST=vioc1
groupadd -g 502 sym61
useradd -u 502 -g sym61 sym61 -d /home/sym61
chown -R 502:502 /home/sym61

export JAVA_HOME=/opt/ibm/java-ppc64-60/bin
/share/power/symcompSetup6.1.0_lnx26-lib25-ppc64.bin --prefix /home/sym61 --dbpath /home/sym61/DB --quiet

su - sym61 -c '
source $HOME/profile.platform
egoconfig join vioc1 -f
egosh ego start -f
'



#1 scp packages to /sym
#2 change hostname to computer*
#3 useradd -d /sym/sym61 sym61
#4 install source env.sh & run symcomSetup6.1.0_lnx26-lib23-x64.bin --prefix /sym/sym61 --dbpath /sym/sym61/DB --quiet
#5 su - sym61 & source /sym/sym61/profile.platform & egoconfig join master1 -f
#6 login as root: source profile.platform & run egosh ego start
#7 check if installed successfully:  egosh resource list &  egosh service list
#8 monitor if installed successfully: watch -n 1 egosh resource list
