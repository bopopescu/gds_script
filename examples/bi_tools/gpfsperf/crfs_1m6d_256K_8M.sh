#!/bin/bash
# $0 <metaReplica> <dataReplica>

metaReplica=$1
dataReplica=$2
set -x
mmcrfs lcfs -F nsdfile_1m6d_256K_8M -A no -Q no  -T /lcfs -r $dataReplica -R $dataReplica -m $metaReplica -M $metaReplica -v no 
#mmchpolicy sncfs cluster.policy
mmchpolicy lcfs cluster.policy
