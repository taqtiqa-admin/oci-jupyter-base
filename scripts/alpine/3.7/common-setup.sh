#!/usr/bin/env sh

# No Requires
echo "############################################"
echo "##"
echo "## Bob: ${0}"
echo "##"
echo "############################################"

export OCI_USER=${OCI_USER:-jovyan}
export OCI_USER_ID=${OCI_USER_ID:-1000}
export OCI_USER_GROUP_ID=${OCI_USER_GROUP_ID:-100}
export OCI_USER_GROUP=$(getent group ${OCI_USER_GROUP_ID}|cut -d: -f1)

export OCI_ORG=${OCI_ORG:-'taqtiqa.io'}
export OCI_AUTHOR=${OCI_AUTHOR:-'TAQTIQA LLC'}
export OCI_EMAIL=${OCI_EMAIL:-'coders@taqtiqa.com'}
export OCI_ARCH=${OCI_ARCH:-'amd64'}
export OCI_OS=${OCI_OS:-'linux'}
