#!/usr/bin/env sh
#
# No Requires

for f in /etc/profile.d/*; do source $f; done

DEFAULT_CONDA_USER=${OCI_USER:-jovyan}
DEFAULT_CONDA_DIR=/opt/conda
DEFAULT_MINICONDA_VERSION='4.3.30'

BUILD_CONDA_USER=${DEFAULT_CONDA_USER}
BUILD_CONDA_DIR=${DEFAULT_CONDA_DIR}
BUILD_MINICONDA_VERSION=${DEFAULT_MINICONDA_VERSION}
BUILD_CONDA_MD5_CHECKSUM="0b80a152332a4ce5250f3c09589c7a81"

PATH="$BUILD_CONDA_DIR/bin:$PATH"

echo "export PATH=${BUILD_CONDA_DIR}/bin:\$PATH" > /etc/profile.d/conda3.sh
echo "export CONDA_DIR=${BUILD_CONDA_DIR}" >> /etc/profile.d/conda3.sh
echo "export MINICONDA_VERSION=${BUILD_MINICONDA_VERSION}" >> /etc/profile.d/conda3.sh
#
# Load required env variables is case we are building 
# in the same shell session
#
for f in /etc/profile.d/*; do source $f; done

cd /tmp 
apk add --no-cache --virtual=.build-dependencies ca-certificates bash
wget --quiet "https://repo.continuum.io/miniconda/Miniconda3-${BUILD_MINICONDA_VERSION}-Linux-x86_64.sh" \
             -O miniconda.sh
echo "${BUILD_CONDA_MD5_CHECKSUM} miniconda.sh" | md5sum -c - 
mkdir -p ${BUILD_CONDA_DIR}
bash miniconda.sh -f -b -p ${BUILD_CONDA_DIR}
rm miniconda.sh 
${BUILD_CONDA_DIR}/bin/conda config --system --prepend channels conda-forge
${BUILD_CONDA_DIR}/bin/conda config --system --set auto_update_conda false
${BUILD_CONDA_DIR}/bin/conda config --system --set show_channel_urls true
${BUILD_CONDA_DIR}/bin/conda update --all --quiet --yes
${BUILD_CONDA_DIR}/bin/conda clean -tipsy
mkdir -p "${BUILD_CONDA_DIR}/locks"
chmod 777 "${BUILD_CONDA_DIR}/locks"

#
# Cleanup
#
rm -f "/root/.wget-hsts"
# Remove bash history
unset HISTFILE
rm -f /root/.bash_history
