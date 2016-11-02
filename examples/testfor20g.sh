#!/bin/bash
echo start at `date`
ftp -n 10.10.0.84<<!
user ftptest 123456
bin
prom
put "|dd if=/dev/zero of=/dev/null bs=10G count=10000"
by
!
echo end at `date` 
