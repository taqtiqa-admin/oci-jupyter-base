#!/usr/bin/env bash
#
# Copyright (C) 2017 TAQTIQA LLC. <http://www.taqtiqa.com>
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

echo "#########################################################"
echo "##"
echo "##  STARTING: $0"
echo "##"
echo "#########################################################"

export BUILDAH_BUILD_ENV='true'

export CI_PACKAGE_MIRROR='http://old-releases.ubuntu.com/ubuntu' # http://archive.ubuntu.com/ubuntu

# In Travis-CI we have a detached HEAD - The branch name the tag is on is not available.
export OCI_RELEASE="$(source ./RELEASE)"
export REPO_VERSION="$(source ./RELEASE)"

export CI_ARTIFACTS_DIR="/tmp/${OCI_RELEASE}"
export DEFAULT_BUILD_ARCH='amd64'
export DEFAULT_BUILD_VERSION="$(source ./RELEASE)"
export DEFAULT_CI='false'
export DEFAULT_COMPONENTS='main,universe,multiverse,restricted'
export DEFAULT_GUEST_PACKAGES='gnupg,dirmngr,busybox,network-manager,apt-utils,language-pack-en,ubuntu-keyring,debian-archive-keyring'
export DEFAULT_GUEST_PACKAGE_MIRROR='http://archive.ubuntu.com/ubuntu' #'http://old-releases.ubuntu.com/ubuntu'
export DEFAULT_HOST_PACKAGE_MIRROR='http://archive.ubuntu.com/ubuntu'
export DEFAULT_VARIANT='minbase'
export DEFAULT_ROOTFS='/tmp/rootfs'
export DEFAULT_RELEASE='master'
export DEFAULT_BUILD_ARTIFACTS_DIR=${CI_ARTIFACTS_DIR:-'/tmp/artifacts'}
export DEFAULT_OCI_NAME="$(basename $(git remote show -n origin | grep Fetch | cut -d: -f2-) .git)"  #: r,littler,rserver no packages installed rkt-rrr-tidy: r,littler,rserver recommends and tidy packages, rkt-rrr-devel: r,littler,rserver recommends and tidy devel environment
export DEFAULT_SLUG="example.com/${DEFAULT_OCI_NAME}"
export DEFAULT_ORG="$(dirname ${DEFAULT_SLUG})"
export DEFAULT_BUILD_ARTIFACTS_DIR=${CI_ARTIFACTS_DIR:-'/tmp/release'}
export DEFAULT_BUILD_EMAIL='no-reply@example.com'
export DEFAULT_BUILD_AUTHOR='Example LLC'

export ROOTFS=${1:-${DEFAULT_ROOTFS}}

export CI_BUILD_VERSION=${TRAVIS_TAG:-${DEFAULT_BUILD_VERSION}}
export CI_SLUG=${TRAVIS_REPO_SLUG:-${DEFAULT_SLUG}}
export CI=${CI:-${DEFAULT_CI}}

export OCI_NAME="$(basename ${CI_SLUG})" #: r, littler, rserver no packages installed rkt-rrr-tidy: r,littler,rserver recommends and tidy packages, rkt-rrr-devel: r,littler,rserver recommends and tidy devel environment

export BUILD_ARCH=${OCI_ARCH:-${DEFAULT_BUILD_ARCH}}
export BUILD_OCI_NAME=${OCI_NAME:-${DEFAULT_OCI_NAME}}
export BUILD_ARTIFACTS_DIR=${CI_ARTIFACTS_DIR:-${DEFAULT_BUILD_ARTIFACTS_DIR}}
export BUILD_AUTHOR=${OCI_AUTHOR:-${DEFAULT_BUILD_AUTHOR}}
export BUILD_COMPONENTS=${OCI_COMPONENTS:-${DEFAULT_COMPONENTS}}
export BUILD_EMAIL=${OCI_EMAIL:-${DEFAULT_BUILD_EMAIL}}
export BUILD_ORG=${OCI_ORG:-${DEFAULT_ORG}}
export BUILD_RELEASE=${OCI_RELEASE:-${DEFAULT_RELEASE}}
export BUILD_GUEST_PACKAGES=${OCI_PACKAGES:-${DEFAULT_GUEST_PACKAGES}}
export BUILD_GUEST_PACKAGE_MIRROR=${CI_PACKAGE_MIRROR:-${DEFAULT_GUEST_PACKAGE_MIRROR}}
export BUILD_VERSION=${CI_BUILD_VERSION:-${DEFAULT_BUILD_VERSION}}
export BUILD_DATE=${BUILD_DATE:-$(date --utc +%FT%TZ)} # ISO8601
export BUILD_SLUG=${DEFAULT_SLUG}
export BUILD_VARIANT=${OCI_VARIANT:-${DEFAULT_VARIANT}}
export BUILD_RELEASE=${OCI_RELEASE:-${DEFAULT_RELEASE}}

export BUILD_FILE=${BUILD_OCI_NAME}-${BUILD_VERSION}-linux-${BUILD_ARCH}
export BUILD_ARTIFACTS_DIR='.'
export BUILD_ARTIFACT=${BUILD_ARTIFACTS_DIR}/${BUILD_FILE}.aci

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANG=C  # https://serverfault.com/questions/350876/setlocale-error-with-chroot
export TERM=linux
export DEBIAN_FRONTEND='noninteractive'

export BUILDAH="sudo $(which buildah)"
export ACBUILD_CHROOT="/bin/acbuild-chroot --chroot ${ROOTFS} --working-dir /tmp"

export BUILD_NAME="${BUILD_ORG}/${BUILD_OCI_NAME}"

if [[ ${CI_BUILD_VERSION} != ${REPO_VERSION} ]]; then
  echo "The CI tag version number and the content of the RELEASE file do not match"
  # exit 1
fi
