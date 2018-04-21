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

echo "############################################"
echo "##"
echo "## Buildah commit ${OCI_NAME} ${OCI_NAME}"
echo "##"
echo "############################################"
OCI_CID=$(${BUILDAH} commit ${OCI_NAME} ${OCI_NAME}) #add -rm in production

echo "############################################"
echo "##"
echo "## Buildah push ${OCI_NAME} oci-archive:${OCI_NAME}-${OCI_TAG}.oci:${OCI_TAG}"
echo "##"
echo "############################################"
OCI_ID=$(${BUILDAH} push ${OCI_NAME} oci-archive:${OCI_NAME}-${OCI_TAG}.oci:${OCI_TAG})

echo "############################################"
echo "##"
echo "## Buildah push ${OCI_NAME} docker-archive:${OCI_NAME}-${OCI_TAG}.docker:${OCI_NAME}"
echo "##"
echo "############################################"
DKR_ID=$(${BUILDAH} push ${OCI_NAME} docker-archive:${OCI_NAME}-${OCI_TAG}.docker:${OCI_NAME})


# upload to docker hub:
# This should be extracted to a CI script so that it is not
# tied to a user or organization.
# Requires authorization state in $HOME/.docker/config.json

# This is only required once, until the username or password is changed
# echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
# chown $(whoami) ${HOME}/.docker
# chown $(whoami) ${HOME}/.docker/config.json
# chmod +r ${HOME}/.docker/config.json

DOCKER_AUTH_TOKEN=dGFxdGlxYWFkbWluOkNhZGFicmEx
mkdir -p ${HOME}/.docker
cat <<EOF >${HOME}/.docker/config.json
{
        "auths": {
                "https://index.docker.io/v1/": {
                        "auth": "${DOCKER_AUTH_TOKEN}"
                }
        },
        "HttpHeaders": {
                "User-Agent": "Docker-Client/18.03.0-ce (linux)"
        }
}
EOF

# Make files readable to skopeo and rkt
chown $(whoami) ${OCI_NAME}-${OCI_TAG}.oci
chown $(whoami) ${OCI_NAME}-${OCI_TAG}.docker

echo "############################################"
echo "##"
echo "## Skopeo Copy FROM: docker-archive:${OCI_NAME}-${OCI_TAG}.docker TO docker://${DOCKER_ORG}/${OCI_NAME}:${OCI_TAG}"
echo "##"
echo "############################################"
${SKOPEO} copy docker-archive:${OCI_NAME}-${OCI_TAG}.docker docker://${DOCKER_ORG}/${OCI_NAME}:${OCI_TAG}

echo "############################################"
echo "##"
echo "## Rkt fetch docker://${DOCKER_ORG}/${OCI_NAME}:${OCI_TAG}"
echo "##"
echo "############################################"
RKT_IMAGE_NAME="registry-1.docker.io/${DOCKER_ORG}/${OCI_NAME}:${OCI_TAG}"
${RKT} fetch --insecure-options=image docker://${DOCKER_ORG}/${OCI_NAME}:${OCI_TAG}

echo "############################################"
echo "##"
echo "## Rkt image export ${RKT_IMAGE_NAME} ${OCI_NAME}-${OCI_TAG}.aci"
echo "##"
echo "############################################"
${RKT} image export ${RKT_IMAGE_NAME} ${OCI_NAME}-${OCI_TAG}.aci

# Make files readable to actool
chown $(whoami) ${OCI_NAME}-${OCI_TAG}.aci

echo "############################################"
echo "##"
echo "## Actool validate ${OCI_NAME}-${OCI_TAG}.aci"
echo "##"
echo "############################################"
${ACTOOL} --debug validate ${OCI_NAME}-${OCI_TAG}.aci

# Now we should have three container formats:
# - OCI
# - Docker
# - Rkt (ACI)

# rm ${OCI_NAME}-${OCI_TAG}.aci
# rm ${OCI_NAME}-${OCI_TAG}.docker
# rm ${OCI_NAME}-${OCI_TAG}.oci
