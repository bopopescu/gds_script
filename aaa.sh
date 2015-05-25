# Name: aaa.sh
# Description:
# Author: Linuxsea
# Datatime: 2014-01-14 16:52:41
# Usage: aaa.sh
USAGE() {
echo "Usage: opttest.sh [-d argu] [-b argu]"
}

while getopts ":b:d:" SWITCH; do
	case $SWITCH in
	   b) echo "The option is b."
	      echo $OPTARG;;
	   d) echo "The option is d."
	      echo $OPTARG;;
	   \?)USAGE;;
	esac
done
