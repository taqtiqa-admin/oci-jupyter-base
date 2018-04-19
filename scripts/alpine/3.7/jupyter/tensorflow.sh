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

#
# Load required env variables: build is in OCI/ACI shell session
#

for f in /etc/profile.d/*; do source $f; done

conda install --quiet --yes \
    'tensorflow=1.3*' \
    'keras=2.0*'

conda clean -tipsy
