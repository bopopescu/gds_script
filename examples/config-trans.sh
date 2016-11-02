#!/bin/sh

scp /tmp/config-ib.sh 172.16.13.68:/tmp

for i in {32..39}; do
	hostname
	scp /tmp/config-ib.sh 172.16.13.$i:/tmp
	ssh 172.16.13.$i '/tmp/config-ib.sh'
done

