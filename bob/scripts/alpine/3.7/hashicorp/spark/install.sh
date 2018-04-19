#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - openjdk7jre/install.sh

# TODO: Nomad-Spark 
# https://github.com/hashicorp/nomad-spark
# https://github.com/hashicorp/nomad/blob/master/terraform/examples/spark/docker/spark/Dockerfile
# https://github.com/djenriquez/nomad/blob/master/Dockerfile
# 
# Apache Spark is integrated with mesos. Which is heavy:
# The Mesos only Docker containers are approx 465MB.  
# The Nomad+Consul only containers are approx 33MB. 
# A factor of ten difference.  This could allow allow the ACI/OCI images to be distributed 
# as Github release artifacts, which have a 2GB size limit.

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export SPARK_HOME=/opt/spark" >> /etc/profile.d/spark.sh
echo "export PATH=${PATH}:${SPARK_HOME}/bin" >> /etc/profile.d/spark.sh

for f in /etc/profile.d/*; do source $f; done

apk update
apk add --virtual .build-dependencies --no-cache wget

mkdir /opt
sprk_dwnld=https://github.com/hashicorp/nomad-spark/releases/download/v2.2.0-nomad-0.7.0-20180326/spark-2.2.0-bin-nomad-0.7.0-20180326.tgz
wget -qO- ${sprk_dwnld} | tar -xzC /opt
