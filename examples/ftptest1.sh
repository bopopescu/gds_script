#!/bin/bash - 
#===============================================================================
#
#          FILE: ftptest1.sh
# 
#         USAGE: ./ftptest1.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/24/2015 07:32:33 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#!/bin/sh

find /u01/backup/backupsets -mtime -1 -name "*" -exec cp -f {} /u01/backup/backuptmp /;

ftp -n 192.168.88.251 << EOF

user user password

bin

lcd /u01/backup/backuptmp

prompt

mput *

bye

EOF

cd /u01/backup/backuptmp

rm -rf /u01/backup/backuptmp/*
