#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - hashicorp/consul/install.sh

#
# Modelled on https://github.com/D1abloRUS/docker-nomad/blob/master/0.X/Dockerfile
# Modelled on https://github.com/hashicorp/docker-consul/blob/master/0.X/Dockerfile
#

#
# Load required env variables: build is in OCI/ACI shell session
#

nomad_ver=0.7.1

echo "export HASHICORP_RELEASES=https://releases.hashicorp.com" >> /etc/profile.d/hashicorp.sh
echo "export NOMAD_VERSION=${nomad_ver}" >> /etc/profile.d/nomad.sh

for f in /etc/profile.d/*; do source $f; done

# Create a nomad user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
addgroup nomad
adduser -S -G nomad nomad

# Set up certificates, our base tools, and Nomad.
apk add --no-cache --virtual=.build-dependencies gnupg openssl

apk add --no-cache ca-certificates bash curl libcap su-exec shadow wget
gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C
mkdir -p /tmp/build
cd /tmp/build
  wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
  wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS
  wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig
  gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS
  grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c
  unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip
cd /tmp
  apk del --purge .build-dependencies
  rm -rf /tmp/build
  rm -rf /root/.gnupg

# The /nomad/data dir is used by Nomad to store state. The agent will be started
# with /nomad/config as the configuration directory so you can add additional
# config files in that location.
mkdir -p /nomad/data
mkdir -p /nomad/config
chown -R nomad:nomad /nomad
chmod 755 /run
groupmod -g 1999 ping
groupmod -g 999 nomad

# Nomad doesn't need root privileges so we run it as the nomad user from the
# entry point script. 
filefrom="/home/bob/scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/hashicorp/nomad/artifacts/nomad-entrypoint.sh"
fileto=/usr/local/bin/nomad-entrypoint.sh
cp $filefrom $fileto
