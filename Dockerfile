FROM ubuntu:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_VERSION 2.7.3

# Install necessary packages
RUN apt-get update &&  apt-get -y install \
    openssh-client \ 
    openssh-server \
    openjdk-8-jre-headless \
    curl

# Download and unpack Hadoop
RUN curl -SL https://www.lockss.org/hadoop/hadoop-${HADOOP_VERSION}.tar.gz | tar xzf -

# Setup pseudo-distributed environment
ADD etc/hadoop/core-site.xml hadoop-${HADOOP_VERSION}/etc/hadoop/core-site.xml
ADD etc/hadoop/hdfs-site.xml hadoop-${HADOOP_VERSION}/etc/hadoop/hdfs-site.xml
ADD etc/hadoop/hadoop-env.sh hadoop-${HADOOP_VERSION}/etc/hadoop/hadoop-env.sh

# Format HDFS namenode
WORKDIR hadoop-${HADOOP_VERSION}
RUN bin/hdfs namenode -format

# Generate SSH keypair to login to localhost
RUN ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Add SSH configuration to image
ADD ssh/config /root/.ssh/config

# Add entrypoint script
ADD scripts/init.sh /init.sh

ENTRYPOINT ["/init.sh"]
