FROM ubuntu:latest

MAINTAINER "Daniel Vargas" <dlvargas@stanford.edu>

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_VERSION 2.7.3

ENTRYPOINT ["/init.sh"]

# Install necessary packages
RUN apt-get update \
 && apt-get -y install openssh-client \
                       openssh-server \
                       openjdk-8-jre-headless \
                       curl \
                       kmod portmap nfs-kernel-server runit inotify-tools

# Download and unpack Hadoop
RUN curl -SL https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar xzf -

# Normalize HDFS location
RUN mv /hadoop-${HADOOP_VERSION} /hadoop
WORKDIR /hadoop

# Add SSH configuration to image
ADD ssh/config /root/.ssh/config

# Add NFS stuff; inspired by https://github.com/cpuguy83/docker-nfs-server
RUN mkdir -p /exports
#RUN mkdir -p /etc/sv/nfs
#ADD scripts/nfs.init /etc/sv/nfs/run
#ADD scripts/nfs.stop /etc/sv/nfs/finish
#ADD scripts/nfs_setup.sh /usr/local/bin/nfs_setup
RUN echo "nfs             2049/tcp" >> /etc/services
RUN echo "nfs             111/udp" >> /etc/services
VOLUME /exports
EXPOSE 111/udp 2049/tcp

# Add entrypoint script
ADD scripts/init.sh /init.sh