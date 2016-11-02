#!/bin/bash
#name : add_crontab.sh
#description : add entry to crontab
#author : Justing Du
#history : Jan 14 2008
#set -x

add_crontab()
{
        _HOST_NAME=$1
        # generate random hour and randmom minute
        #_RANDOM_HOUR=`rsh $_HOST_NAME "awk 'BEGIN{srand();print int(100*rand()%24)}'"`
        _RANDOM_HOUR=`rsh $_HOST_NAME "awk 'BEGIN{srand();print int(100*rand()%6)}'"`
        _RANDOM_MINUTE=`rsh $_HOST_NAME "awk 'BEGIN{srand();print int(100*rand()%60)}'"`

        MINUTE_HOUR="${_RANDOM_MINUTE} ${_RANDOM_HOUR}" 
        COMMAND="/corp/sysadmin/fr_scripts/check_automount.sh auto_master_s3glinux"

	LINE=`rsh $_HOST_NAME crontab -l |sed '/^ *#/d'| grep "$COMMAND" |wc -l`
	if [ $LINE -eq 0 ]
	then
                echo "$MINUTE_HOUR * * * * $COMMAND" # >>/var/spool/cron/shelladm"
                rsh $_HOST_NAME "echo "$MINUTE_HOUR "'* * * *'" $COMMAND " '>/dev/null' >>/var/spool/cron/root"
                rsh $_HOST_NAME /etc/rc.d/init.d/crond restart
	else
		echo "the entry already existed in crontab"
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

printf "define the host range\n"
printf " first host name [e.g. cpu0001]:"
read firsthost
printf " last host name [e.g. cpu0002] :"
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

for letters in cpu mce bj
do
	echo ${firsthost} | grep ^${letters} >/dev/null
	if [ $? -eq 0 ]
	then
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

	
num=${num1}
while [ ${num} -le ${num2} ]
do
	
	postfix=`expr $num + 10000 |awk '{print substr($1,2,4)}'`
	HOST_NAME=${prefix}${postfix}

	echo "checking ${HOST_NAME}..........."
	
	RSH_STAT=`perl ./testrsh.pl ${HOST_NAME}`

	if [ -z ${RSH_STAT} ]
	then
		printf "\t\t maybe no rsh service!!\n"
		num=`expr ${num} + 1`
		continue
	fi

	if [ ${RSH_STAT} = "rshok" ]
	then
		#add_crontab ${HOST_NAME}
		echo "invoke function here"
	else
		echo "${RSH_STAT}!!"
	fi

	num=`expr ${num} + 1`
done
