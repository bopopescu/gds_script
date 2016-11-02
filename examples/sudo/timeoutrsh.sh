#!/bin/sh 
#set -x


timeout=$1 
case $timeout in 
[1-9]*) shift;; 
*) timeout=10;; 
esac 


case $# in 
0) echo 'Usage: timeoutrsh [timeout] cmd' >&2; exit;; 
esac 


ssh "$@" & 
p=$! 
(sleep $timeout; kill -1 $p) & 
k=$! 


wait $p 
exit=$? 
#  Normal exits are 0..127, signals are 128+signo 
case $exit in 
129) 
        echo '(timed out)' >&2 
        ;; 
*) 
        #  Kill the killer. 
        kill $k 
        ;; 
esac 
exit $exit 



