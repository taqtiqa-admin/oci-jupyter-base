#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - openjdk7/install.sh

# TODO: Nomad-Spark 
# https://github.com/hashicorp/nomad-spark
# https://github.com/hashicorp/nomad/blob/master/terraform/examples/spark/docker/spark/Dockerfile
# https://github.com/djenriquez/nomad/blob/master/Dockerfile
# 
# Apache Spark is integrated with mesos. Which is heavy:
# The Mesos only Docker containers are approx 465MB.  
# The Nomad+Consul only containers are approx 33MB. 
# A factor of ten difference.  Consul+Nomad could allow the ACI/OCI images to be distributed 
# as Github release artifacts, which have a 2GB size limit.

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export HADOOP_VERSION=2.7.3" >> /etc/profile.d/hdfs.sh
echo "export HADOOP_PREFIX=/usr/local/hadoop-${HADOOP_VERSION}" >> /etc/profile.d/hdfs.sh
echo "export PATH=${PATH}:${HADOOP_PREFIX}/bin" >> /etc/profile.d/hdfs.sh

for f in /etc/profile.d/*; do source ${f}; done

wget -O - http://apache.mirror.iphh.net/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar xz -C /usr/local/

mkdir -p ${HADOOP_PREFIX}/etc/hadoop
ffrom=/home/bob/scripts/${DISTRIB_ID}/${DISTRIB_CODENAME}/hdfs/artifacts/${HADOOP_PREFIX}/etc/hadoop/core-site.xml 
fto=${HADOOP_PREFIX}/etc/hadoop/core-site.xml
cp ${ffrom} ${fto}
