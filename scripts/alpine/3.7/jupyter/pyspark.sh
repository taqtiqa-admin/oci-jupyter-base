#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - miniconda3/install.sh
# - jupyter/install.sh
# - pandoc/install.sh
# - aports/install.sh
# - jupyter/minimal.sh
# - jupyter/scipy.sh
# - hashicorp/consul/install.sh
# - hashicorp/nomad/install.sh
# - hashicorp/spark/install.sh

# TODO: Nomad-Spark 
# https://github.com/hashicorp/nomad-spark
# https://github.com/hashicorp/nomad/blob/master/terraform/examples/spark/docker/spark/Dockerfile
# https://github.com/djenriquez/nomad/blob/master/Dockerfile
# 
# Spark is integrated with mesos. Which is heavy - the official mesos only 
# containers are approx 465MB.  The Nomad+Consul only containers are approx 33MB. 
# A factor of ten difference.  This would allow the ACI/OCI images to be distributed 
# via Github, which has a 2GB limit on artifacts.

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export APACHE_SPARK_VERSION=2.3.0" >> /etc/profile.d/spark.sh
echo "export HADOOP_VERSION=2.7" >> /etc/profile.d/spark.sh
echo "export PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.6-src.zip"
echo "SPARK_OPTS='--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info'"
for f in /etc/profile.d/*; do source $f; done

apk update
apk add --virtual .build-dependencies --no-cache alpine-sdk wget

apk add --no-cache openjdk8 java-cacerts

#
# Upstream installs Apache spark for use with mesosphere
# Here we use Hashicorp's Spark for use with Nomad
#
cd /tmp
  wget -q http://apache.claz.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
  echo "258683885383480BA01485D6C6F7DC7CFD559C1584D6CEB7A3BBCF484287F7F57272278568F16227BE46B4F92591768BA3D164420D87014A136BF66280508B46 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c -
  tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local --owner root --group root --no-same-owner
  rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
cd /usr/local 
  ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# Upstream (Jupyter) installs mesos for use with spark.
# Here we use Nomad + Spark - perhaps more elegant, seemingly lighter
# Sizes come from official Docker Hub for Mesosphere and Hahicorp(Cosul)
# https://hub.docker.com/r/djenriquez/nomad/
#
# Mesos (Master+slave) v1.5.0: 465 MB | 18 + 15 = 33 MB Nomad + Consul (1.0.7)
# Mesos (Master)       v1.5.0: 465 MB | 
# Mesos (Slave)        v1.5.0: 465 MB | 

# Install pyarrow
conda install --quiet -y 'pyarrow'
fix-permissions ${CONDA_DIR} 
fix-permissions /home/${NB_USER}
