#!/bin/sh

# Generate SSH keypair to login to localhost
ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Start OpenSSH
service ssh start

# Copy custom configuration
if [ -d /hadoop/etc/hadoop.custom ]; then
    cp /hadoop/etc/hadoop.custom/* /hadoop/etc/hadoop/.
fi

# Format HDFS NameNode
bin/hdfs namenode -format

# Start HDFS
echo ${JAVA_HOME}
/hadoop/sbin/start-dfs.sh

# Show log files indefinitely
tail -f logs/*.log logs/*.out
