#!/usr/bin/env sh

# Requires:
#
# - setup.sh

#
# Modelled on https://github.com/hashicorp/docker-consul/blob/master/0.X/Dockerfile
#

#
# Load required env variables: build is in OCI/ACI shell session
#

consul_ver=1.0.7

echo "export HASHICORP_RELEASES=https://releases.hashicorp.com" >> /etc/profile.d/hashicorp.sh
echo "export CONSUL_VERSION=${consul_ver}" >> /etc/profile.d/consul.sh

for f in /etc/profile.d/*; do source $f; done

apk update
apk add --virtual .build-dependencies --no-cache wget gnupg openssl

# Set up certificates, base tools, and Consul.
apk add --no-cache bash ca-certificates curl libcap su-exec shadow

# Create a consul user and group first so the IDs get set the same way, even as
# the rest of this may change over time.
addgroup consul
adduser -S -G consul consul

gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C
mkdir -p /tmp/build
cd /tmp/build
  wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
  wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
  wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig
  gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS
  grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c
  unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip
cd /tmp
  apk del --purge .build-dependencies
  rm -rf /tmp/build
  rm -rf /root/.gnupg

# The /consul/data dir is used by Consul to store state. The agent will be started
# with /consul/config as the configuration directory so you can add additional
# config files in that location.
mkdir -p /consul/data
mkdir -p /consul/config
chown -R consul:consul /consul

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. 
filefrom="/home/bob/scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/hashicorp/consul/artifacts/consul-entrypoint.sh"
fileto=/usr/local/bin/consul-entrypoint.sh
cp $filefrom $fileto

#########
##
## See buildah-config.sh
##
#########