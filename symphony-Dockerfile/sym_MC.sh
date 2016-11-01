#!/bin/bash
clear
#set -x
check_variable()
{
        if [ -z $1 ]
        then
                echo "are you kidding me ? pls answer all the question."
                exit
        fi
}

cd ./

printf "Define the master&computer\n"
printf "Please input master host name [e.g. mn0] :"
read masterhost
printf "Please input host name [e.g. cn0] :"
read comhost
printf "Please input computer node number [e.g. 1...n] :"
read Number
docker images
printf "Please input build image  [e.g. symphony/docker:1.2 ] :"
read buildimg
check_variable ${masterhost}
check_variable ${comhost}
check_variable ${buildimg}
#check_variable ${ClientNumber}

printf "Master:$masterhost Computer:$comhost(1...n) Use_image:$buildimg Computer node:$Number, Continue? [y/n]"
read CONTINUE
printf "\n"
if [ -z ${CONTINUE} ]
then
        echo "exit the program !"
        exit
fi

if [ ${CONTINUE}  = "y" ]
then
        echo "continuing the progrem...."
else
        echo "exit the program ."
        exit
fi

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

#M="mn01"
#C="cn0"
DNSIP=`/sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'|grep -v 127|grep -v 172|grep -v 169`
ClientNumber=${Number}
docker run  -i -t -P --privileged=true --dns=$DNSIP  --name=$masterhost --hostname=$masterhost $buildimg  M D
#MasterName=docker ps |grep -v CONTAINER|awk '{print $11}'
MasterIP=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' $masterhost`
Comm_CIP=`echo "$MasterIP"|awk -F "[. ]" '{print $1"."$2"."$3}'`
echo "$Comm_CIP";
Format="address=/$masterhost.demo.org/$MasterIP"
rm -rf /etc/dnsmasq.d/symphony.conf 
echo "$Format" > /etc/dnsmasq.d/symphony.conf
CIP=`echo "$MasterIP"|awk -F "[. ]" '{print int($4)}'`
docker ps

for ((i=1;i<=ClientNumber;i++))
do 
CIPP=$(($CIP+$i))
echo "address=/$comhost$i.demo.org/$Comm_CIP.$CIPP" >> /etc/dnsmasq.d/symphony.conf 
done

echo "server=/#/$DNSIP" >> /etc/dnsmasq.d/symphony.conf
service dnsmasq restart
echo "search demo.org" >> /etc/resolv.conf

for ((ii=1;ii<=ClientNumber;ii++))
do
docker run  -i -t -P  --privileged=true --dns=$DNSIP  --name="$comhost$ii" --hostname="$comhost$ii" $buildimg C D $masterhost
done
docker ps
