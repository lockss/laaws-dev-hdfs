#!/bin/sh

# Start OpenSSH
service ssh start

# Start HDFS
echo ${JAVA_HOME}
/hadoop-${HADOOP_VERSION}/sbin/start-dfs.sh

# Show log files
tail -f logs/*.log logs/*.out
