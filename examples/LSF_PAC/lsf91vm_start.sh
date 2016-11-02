#!/bin/bash

clear
restart_autolsf()
{
   HOST=$1
   AUTOFS=`ssh ${HOST} ls /etc/init.d/autofs |wc -l`
   if [ ${AUTOFS} -ne 0 ]
   then
	echo "Restarting LSF ..."
	ssh ${HOST}  source /sncfs/LSF911/conf/profile.lsf
        ssh ${HOST}  /sncfs/LSF911/9.1/linux2.6-glibc2.3-x86_64/etc/lsf_daemons stop
        #ssh ${HOST}  /sncfs/LSF911/9.1/linux2.6-glibc2.3-x86_64/etc/lsf_daemons start
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
printf "first host name [e.g. v5com1]:"
read firsthost
printf "last host name [e.g. v5com6]:"
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
for letters in computer v5com
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
                echo "${HOST_NAME}" >>/users/wanggl/autofs_restart/failed.host
                printf "\t\t maybe no ssh service!!\n"
                num=`expr ${num} + 1`
                continue
        fi
	num=`expr ${num} + 1`
done
_PAC=v5com2
echo "Restart PAC ...."
ssh $_PAC  'source /sncfs/PAC91/profile.platform;pmcadmin stop;perfadmin stop all'
#ssh $_PAC  'csh;source /sncfs/PAC91/profile.platform;pmcadmin start;perfadmin start all'
