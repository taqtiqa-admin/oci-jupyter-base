#!/usr/env/bin bash

#
# Buildah config settings to be applied to the Container
#

if [ -z ${BUILDAH+x} ]; 
  then 
    echo "BUILDAH is unset. This scripts configures a container."
    exit 1
  else 
    echo "BUILDAH is set to '$BUILDAH'."
fi

${BUILDAH} config --author "${OCI_AUTHOR}" \
        --cmd "agent -dev -client 0.0.0.0" \
        --entrypoint "/usr/local/bin/consul-entrypoint.sh" \
        --port 8888/tcp \
        --port 8300/tcp \
        --port 8301/tcp \
        --port 8301/udp \
        --port 8302/tcp \
        --port 8302/udp \
        --port 8500/tcp \
        --port 8600/tcp \
        --port 8600/udp \
        --shell "/bin/bash -E" \
        --user ${OCI_USER} \
        --volume "/consul/data" \
        --workingdir "/home/${OCI_USER}" \
        ${OCI_NAME}
# Expose the consul data directory as a volume since there's mutable state in there.
#--volume "/consul/data"

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
#--port=8300

# Serf LAN and WAN (WAN is used only by Consul servers) are used for gossip between
# Consul agents. LAN is within the datacenter and WAN is between just the Consul
# servers in all datacenters.
#--port=8301 8301/udp 8302 8302/udp

# HTTP and DNS (both TCP and UDP) are the primary interfaces that applications
# use to interact with Consul.
#--port=8500 8600 8600/udp

# Consul doesn't need root privileges so we run it as the consul user from the
# entry point script. The entry point script also uses dumb-init as the top-level
# process to reap any zombie processes created by Consul sub-processes.
#--entrypoint="/usr/local/bin/consul-entrypoint.sh"

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
#--cmd "agent -dev -client 0.0.0.0"
