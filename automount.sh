#!/bin/bash 

SERVER=172.20.5.238

wget -O /etc/auto.master http://$SERVER/auto.master
wget -O /etc/auto.home http://$SERVER/auto.home
wget -O /etc/auto.pcc http://$SERVER/auto.pcc
wget -O /etc/auto.scratch http://$SERVER/auto.scratch
service autofs restart
echo "Autofs set ok"
