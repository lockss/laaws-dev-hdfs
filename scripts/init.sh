#!/bin/sh

# Start OpenSSH
service ssh start

# Start HDFS
echo ${JAVA_HOME}
/hadoop-${HADOOP_VERSION}/sbin/start-dfs.sh

# Drop into a shell
/bin/bash
