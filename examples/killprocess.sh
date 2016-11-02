#!/bin/bash	
HOST_LIST="vpower1 vpower2 vpower3 vpower4 vpower5 vpower6"
SSH_PORT=22

for loop in $HOST_LIST
do
 echo "executing in $loop:"
 ssh -p $SSH_PORT $loop "$1"
 echo
done

