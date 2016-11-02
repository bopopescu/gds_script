#!/bin/bash

clear
restart_autolsf()
{
   HOST=$1
   AUTOFS=`ssh ${HOST} ls /etc/init.d/autofs |wc -l`
   if [ ${AUTOFS} -ne 0 ]
   then
	echo "restarting autofs ..."
	ssh ${HOST}  source /sncfs/LSF9.1/conf/profile.lsf
        ssh ${HOST}  /sncfs/LSF9.1/9.1/linux2.6-glibc2.3-x86_64/etc/lsf_daemons stop
        ssh ${HOST}  /sncfs/LSF9.1/9.1/linux2.6-glibc2.3-x86_64/etc/lsf_daemons start
   fi
}
	

check_variable()
{
	if [ -z $1 ]
	then
		echo "are you kidding me ? pls answer all the question."
		exit
	fi
}

cd ./

printf "please enter the host range\n"
printf "first host name [e.g. master0/pmastar0/computer2/power1]:"
read firsthost
printf "last host name [e.g. pmaster1/pmaster0/computer9/power4]:"
read lasthost
printf "\n"

check_variable ${firsthost}
check_variable ${lasthost}

printf "The hosts range : ${firsthost} --${lasthost} , continue? [y/n]"
read CONTINUE

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

name_err=1
for letters in computer power master pmaster
do
	echo ${firsthost} | grep ^${letters} >/dev/null
	if [ $? -eq 0 ]
	then
		name_err=0		
		prefix=${letters}
		num1=`echo ${firsthost}|sed "s/^${letters}//g"`
		num2=`echo ${lasthost}|sed "s/^${letters}//g"`
		if [ ${num1} -gt ${num2} ]
		then
			echo "input error! first host > last host, exit."
			exit
		fi
		echo ${lasthost} | grep ^${letters} >/dev/null
		if [ $? -ne 0 ]
		then
			echo "input error! different prefix , exit."
			exit
		fi
	fi
done

if [ ${name_err} -eq 1 ]
then
	echo "error hostname !!"
	exit
fi

	
num=${num1}
while [ ${num} -le ${num2} ]
do
	
	postfix=`expr $num + 10 |awk '{print substr($1,2,4)}'`
	HOST_NAME=${prefix}${postfix}

        echo ------------ ${HOST_NAME} ----------------
        ### check if the ssh service works
        ./timeoutrsh.sh 2 ${HOST_NAME} hostname >/dev/null
        RSH_STAT=$?

        if [ ${RSH_STAT} -eq 0 ]
        then
                restart_autolsf ${HOST_NAME} 
        else
                echo "${HOST_NAME}" >>/users/wanggl/lfs_restart/failed.host
                printf "\t\t maybe no lsf service!!\n"
                num=`expr ${num} + 1`
                continue
        fi
	num=`expr ${num} + 1`
done
####start PAC ....
ssh master0  source  /sncfs/PAC91/profile.platform
pmcadmin start
perfadmin start all
