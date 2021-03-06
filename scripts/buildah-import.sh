#!/usr/bin/env bash
#
#    Copyright (C) 2018 TAQTIQA LLC. <http://www.taqtiqa.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU Affero General Public License v3
# along with this program.
# If not, see <https://www.gnu.org/licenses/agpl-3.0.en.html>.


source ./bob/scripts/${OCI_DISTRIB_ID}/${OCI_DISTRIB_CODENAME}/setup.sh

#
# Fetch the base image in OCI format
# 
echo "############################################"
echo "##"
echo "## Skopeo Copy FROM: docker://${DOCKER_ORG}/${OCI_BASE_NAME}:${OCI_BASE_TAG}  TO oci:${OCI_BASE_NAME}-${OCI_BASE_TAG}:${OCI_BASE_TAG}"
echo "##"
echo "############################################"
rm -f ${OCI_BASE_NAME}-${OCI_BASE_TAG}
rm -f ${OCI_BASE_NAME}-${OCI_BASE_TAG}.oci
${SKOPEO} copy docker://${DOCKER_ORG}/${OCI_BASE_NAME}:${OCI_BASE_TAG} oci:${OCI_BASE_NAME}-${OCI_BASE_TAG}:${OCI_BASE_TAG}
tar cf ${OCI_BASE_NAME}-${OCI_BASE_TAG}.oci -C ${OCI_BASE_NAME}-${OCI_BASE_TAG} .
rm -rf ${OCI_BASE_NAME}-${OCI_BASE_TAG}

echo "############################################"
echo "##"
echo "## Buildah from ${OCI_NAME} oci-archive:${OCI_BASE_NAME}-${OCI_BASE_TAG}.oci"
echo "##"
echo "############################################"
${BUILDAH} rm --all # in CI
${BUILDAH} rmi --all # in CI
${BUILDAH} from --name ${OCI_NAME} oci-archive:${OCI_BASE_NAME}-${OCI_BASE_TAG}.oci

${BUILDAH} run ${OCI_NAME} -- mkdir -p /bob 

echo "############################################"
echo "##"
echo "## Buildah copy FROM ./bob/scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/ TO /bob"
echo "##"
echo "############################################"
${BUILDAH} copy ${OCI_NAME} \
                "./bob/scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/" \
                '/bob'
