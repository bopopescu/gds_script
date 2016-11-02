#!/bin/bash
echo start at `date`
ftp -n 9.111.143.51<<!
user ftptest 123456
bin
prom
put "|dd if=/dev/zero of=/dev/null  bs=1G count=100"
by
!
echo end at `date` 
