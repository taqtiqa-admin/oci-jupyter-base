#!/usr/bin/env bash
#
# Copyright (C) 2018 TAQTIQA LLC. <http://www.taqtiqa.com>
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License v3
#along with this program.
#If not, see <https://www.gnu.org/licenses/agpl-3.0.en.html>.
#

# REQUIREMENTS: build host 
# ========================
# These are NOT installed into the container.
# 1) buildah
# 2) docker2aci 

# Usage:
#   ./buildda.sh container-name
#

export OCI_AUTHOR="TAQTIQA LLC <coders@taqtiqa.com>"
export OCI_BASE_NAME=alpine
export OCI_BASE_TAG=3.7
export OCI_NAME=${1:-oci-jupyter-base}
export OCI_TAG=$(date --utc +%Y%m%d)

export BUILDAH="sudo buildah"

source bob/scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/common-setup.sh

#
# Fetch the base image in OCI format
# 
${BUILDAH} rm ${OCI_NAME}
${BUILDAH} rmi ${OCI_NAME}
${BUILDAH} from --name ${OCI_NAME} docker://${OCI_BASE_NAME}:${OCI_BASE_TAG}
#${BUILDAH} from --name ${OCI_NAME} oci:${OCI_BASE_NAME}:${OCI_BASE_TAG}

# ${BUILDAH} run --tty ${OCI_NAME} /bin/sh

${BUILDAH} run ${OCI_NAME} -- mkdir /bob 

# Copy ${OCI_BASE_NAME}/${OCI_BASE_TAG} scripts and artifacts
${BUILDAH} copy ${OCI_NAME} \
                "./scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/" \
                '/bob'

# Run build scripts
# - glibc
# - miniconda3
# - jupyter
${BUILDAH} run ${OCI_NAME} -- sh /bob/setup.sh && \
${BUILDAH} run ${OCI_NAME} -- sh /bob/glibc/install.sh && \
${BUILDAH} run ${OCI_NAME} -- sh /bob/miniconda3/install.sh && \
${BUILDAH} run ${OCI_NAME} -- sh /bob/jupyter/install.sh && \
${BUILDAH} run ${OCI_NAME} -- sh /bob/cleanup.sh && \
${BUILDAH} run ${OCI_NAME} -- rm -rf /bob 

${BUILDAH} config --author="${OCI_AUTHOR}" \
        --shell="/bin/bash -E" \
        --workingdir="/home/${OCI_USER}" \
        --user=${OCI_USER} \
        --port=8888/tcp \
        --entrypoint="/usr/local/bin/start.sh jupyter lab" ${OCI_NAME}

# Commit changes to OCI layout 
${BUILDAH} commit ${OCI_NAME} ${OCI_NAME} #add -rm in production
# Export to OCI format in the local directory.
${BUILDAH} push ${OCI_NAME} oci-archive:${OCI_NAME}:${OCI_TAG}

# Conversion step creates ${OCI_NAME}.aci
sudo chown $(whoami) ${OCI_NAME}
#  Output filename pattern:
# library-${OCI_NAME}-${OCI_TAG}.aci
./docker2aci -image=${OCI_NAME}:${OCI_TAG} ${OCI_NAME}
rm ${OCI_NAME}
find ./ -name "*${OCI_NAME}-${OCI_TAG}.aci" -exec mv {}  ${OCI_NAME}-${OCI_TAG}.aci  \;
