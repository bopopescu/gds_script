#Apache Hadoop 2.4.1 Docker image
#docker stop $(docker ps -a -q)
#docker rm $(docker ps -a -q)
#docker run -i -t -h "m01"  platform/docker:3.4 M -bash
#docker run -i -t -h "c01"  platform/docker:3.4 C -bash m01


#pull the basement image
docker pull sequenceiq/hadoop-docker:2.4.1

# Build the image
If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build -t="sequenceiq/hadoop-cluster-docker:2.4.1" .
```
# Start a container

```
docker run  -i -t --net=host  sequenceiq/hadoop-docker:v2.4.1 $1 $2 $3 $4 $5
$1:master ip,such as 192.168.1.4
$2:hdfs port,such as 9001
$3:namenode(N) or datanode(D)
$4:number of hdfs replication,such as 1 or 2
$5:default command,such as -bash or -d

#start name node
eg: docker run  -i -t --privileged  --net=host sequenceiq/hadoop-cluster-docker:2.4.1 192.168.1.4 9001 N 1 -bash

#start data node
eg: docker run  -i -t --privileged  --net=host sequenceiq/hadoop-cluster-docker:2.4.1 192.168.1.4 9001 D 1 -bash

```

## Testing
You can run one of the stock examples:
```
cd $HADOOP_PREFIX
# run the mapreduce
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.1.jar grep input output 'dfs[a-z.]+'

# check the output
bin/hdfs dfs -cat output/*
```
