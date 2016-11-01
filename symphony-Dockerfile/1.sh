#!/bin/bash
clear
set -x

M="mn01"
C="cn0"
ClientNumber=4
#MasterName=docker ps |grep -v CONTAINER|awk '{print $11}'
Comm_CIP=`echo "172.20.0.20"|awk -F "[. ]" '{print $1"."$2"."$3}'`
echo "Comm_CIP";
Format="address=/$M.demo.org/$MasterIP"
rm -rf /etc/dnsmasq.d/symphony.conf 
echo "$Format" > /etc/dnsmasq.d/symphony.conf
CIP=`echo "$MasterIP"|awk -F "[. ]" '{print int($4)}'`

for ((i=1;i<=ClientNumber;i++))
do 
CIPP=$(($CIP+$i))
echo "address=/$C$i.demo.org/$Comm_CIP.$CIPP" >> /etc/dnsmasq.d/symphony.conf 
done
service dnsmasq restart

