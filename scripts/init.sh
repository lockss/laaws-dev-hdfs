#!/bin/sh

# Copyright (c) 2000-2018, Board of Trustees of Leland Stanford Jr. University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

##
## function Apply_Template
##
Apply_Template()
{
  local FILE="${1}"
  sed -i \
      -e "s@\${x.hdfs.host}@${HDFS_HOST:-localhost}@g" \
      -e "s@\${x.hdfs.fsmd}@${HDFS_FSMD:-9000}@g" \
      -e "s@\${x.hdfs.data}@${HDFS_DATA:-50010}@g" \
      -e "s@\${x.hdfs.md}@${HDFS_MD:-50020}@g" \
      -e "s@\${x.hdfs.statui}@${HDFS_STATUI:-50070}@g" \
      -e "s@\${x.hdfs.dnui}@${HDFS_DNUI:-50075}@g" \
      "${FILE}"
}

# Generate SSH keypair to login to localhost
ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Start OpenSSH
service ssh start

# Copy custom configuration
if [ -d /hadoop/etc/hadoop.custom ]; then
  for f in /hadoop/etc/hadoop.custom/* ; do
    cp "${f}" /hadoop/etc/hadoop/
    Apply_Template "/hadoop/etc/hadoop/$(basename "${f}")"
  done
fi

# Format HDFS NameNode
bin/hdfs namenode -format

# Start HDFS
echo ${JAVA_HOME}
/hadoop/sbin/start-dfs.sh

# Wait a bit
sleep 15

# Bring up Hadoop through FUSE
mkdir --mode=777 --parents /mnt/hdfsfuse
hadoop-fuse-dfs "dfs://localhost:${HDFS_FSMD}" /mnt/hdfsfuse

# Show log files indefinitely
tail -f logs/*.log logs/*.out