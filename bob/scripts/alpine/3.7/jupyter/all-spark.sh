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
# - jupyter/r.sh
# - hashicorp/consul/install.sh
# - hashicorp/nomad/install.sh
# - hashicorp/spark/install.sh
# - jupyter/pyspark.sh

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

for f in /etc/profile.d/*; do source $f; done

# Apache Toree kernel
pip install --no-cache-dir https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0-incubating-rc4/toree-pip/toree-0.2.0.tar.gz
jupyter toree install --sys-prefix
rm -rf /home/${NB_USER}/.local
fix-permissions ${CONDA_DIR}
fix-permissions /home/${NB_USER}

# Spylon-kernel
RUN conda install --quiet --yes 'spylon-kernel=0.4*'
conda clean -tipsy
python -m spylon_kernel install --sys-prefix
rm -rf /home/${NB_USER}/.local
fix-permissions ${CONDA_DIR}
fix-permissions /home/${NB_USER}