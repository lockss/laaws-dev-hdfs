FROM ubuntu:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_VERSION 2.7.3

ENTRYPOINT ["/init.sh"]

# Install necessary packages
RUN apt-get update \
 && apt-get -y install wget \
 && wget 'https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/cloudera.list' -O /etc/apt/sources.list.d/cloudera.list \
 && wget https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/archive.key -O /tmp/archive.key \
 && apt-key add /tmp/archive.key \
 && apt-get update \
 && apt-get -y install openssh-client \ 
                       openssh-server \
                       openjdk-8-jre-headless \
                       curl \
                       kmod \
                       hadoop-hdfs-fuse

# Download and unpack Hadoop
RUN curl -SL https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar xzf -

# Normalize HDFS location
RUN mv /hadoop-${HADOOP_VERSION} /hadoop
WORKDIR /hadoop

# Add SSH configuration to image
ADD ssh/config /root/.ssh/config

# Add entrypoint script
ADD scripts/init.sh /init.sh