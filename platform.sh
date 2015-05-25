#!/bin/bash
Platform_var=2
###############
#  Main menu  #
###############
main_menu()
{
#echo
echo
dis_mainmenu="PlatformComputing SCRIPT V1.0"
curdate=`date "+%Y-%m-%d %T"`
cat << mayday
                DATE : $curdate
                =====================================
                $dis_mainmenu
                =====================================
                   **   1)RedHat LDAP/AutoFS
                   **   2)Suse LDAP/AutoFS
                   **   3)Set LDAP env
                   **   4)Set AutoFS env
                   **   5)Set DNS
                   **   6)Get IP from DHCP
               	   **   7)Backup Script
                   **   8)EXIT
                =====================================
mayday
}

############### MAIN BEGIN ############
while [ $Platform_var -gt 0 ]
do
{
        main_menu
        echo -n "               Please choose [1-8]:"
        read main_choice
        case $main_choice in
                1)
			SERVER=9.111.143.101
			LDAP1=bj1ldap1.eng.platformlab.ibm.com
			LDAP2=bj1ldap2.eng.platform.ibm.com

			#Liu Xin Chun platformservice
			touch /etc/SYSTEMCONFIGURED
			wget -O /etc/init.d/platformservice ftp://labvmserv.eng.platformlab.ibm.com/virtroot/config/scripts/platformservice
			chmod +x /etc/init.d/platformservice
			chkconfig --add platformservice
			/etc/init.d/platformservice start

			#wget -O /etc/init.d/platformservice http://9.111.143.101/platformservice
			#disable NIS and enable, setup LDAP settings
			/usr/sbin/authconfig --disablenis --update > /dev/null
			echo "NIS authorization disabled"
			#/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=bj1ldap1.eng.platformlab.ibm.com,bj1ldap2.eng.platform.ibm.com --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
			/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=bj1ldap1.eng.platformlab.ibm.com --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
			echo "LDAP authorization enabled"

			#setup auto mount and restart autofs
			wget -O /etc/auto.master http://$SERVER/auto.master > /dev/null
			wget -O /etc/auto.home http://$SERVER/auto.home > /dev/null
			wget -O /etc/auto.pcc http://$SERVER/auto.pcc > /dev/null
			wget -O /etc/auto.scratch http://$SERVER/auto.scratch > /dev/null
			service autofs restart
			echo "Autofs set ok"
			###################################################################
            		exit
                	;;

                2)
                        touch /etc/SYSTEMCONFIGURED
                        wget -O /etc/init.d/platformservice ftp://labvmserv.eng.platformlab.ibm.com/virtroot/config/scripts/platformservice
                        chmod +x /etc/init.d/platformservice
			insserv -f platformservice
                        /etc/init.d/platformservice start
			######SUSE NIS disable and LDAP setup######
                        #/usr/sbin/authconfig --disablenis --update > /dev/null
                        #echo "NIS authorization disabled"
                        #/usr/sbin/authconfig --enableldap --enableldapauth --ldapserver=bj1ldap1.eng.platformlab.ibm.com --ldapbasedn="dc=platformlab,dc=ibm,dc=com" --update > /dev/null
                        #echo "LDAP authorization enabled"
                        #setup auto mount and restart autofs
                        wget -O /etc/auto.master http://$SERVER/auto.master > /dev/null
                        wget -O /etc/auto.home http://$SERVER/auto.home > /dev/null
                        wget -O /etc/auto.pcc http://$SERVER/auto.pcc > /dev/null
                        wget -O /etc/auto.scratch http://$SERVER/auto.scratch > /dev/null
                        service autofs restart
                        echo "Autofs set ok"
                        ###################################################################
            		exit
            		;;

            	3)
			echo -n "Do you want to download jdk-6u26-linux-i586.bin [Yes|No]?"
				read result
				case $result in
				  y|Y|Yes|yes)
				    /usr/bin/scp 172.20.192.87:/data/backup/dsgong/software/jdk-6u26-linux-i586.bin /usr
				    cd /usr
				    chmod +x /usr/jdk-6u26-linux-i586.bin
				    /bin/sh /usr/jdk-6u26-linux-i586.bin
				    echo "export JAVA_HOME=/usr/jdk1.6.0_26" >> /etc/profile
				    echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
				    echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /etc/profile
				    source /etc/profile
				    java -version
				    echo "Please check the JAVA version is 1.6.0_26, if not please check /usr/bin/java"
				    exit
				    ;;
				*)
				  exit
				  ;;
				esac
            		exit
            		;;
	    	4)
			echo "export PS1='\[\033[1;31m\][PSB] \u@\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[00m\]# '" >> /root/.bash_profile
			source /root/.bash_profile
			exit
			;;
		6)
			/etc/init.d/network restart
			dhclient
			exit
			;;
		7)
			echo -n "Please choose the file you want to backup:"
			read file
			#/usr/bin/rsync -avz $file 172.20.192.87:/data/backup/dsgong/platform.sh
			scp $file 172.20.192.87:/data/backup/dsgong/platform.sh
			exit
			;;
            	8)
            		exit;
            		;;

        esac

}

done

############### END ###############
