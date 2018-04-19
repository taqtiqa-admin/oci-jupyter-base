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
        --cmd "agent -dev" \
        --entrypoint "/usr/local/bin/nomad-entrypoint.sh" \
        --port 4646/tcp \
        --port 4647/tcp \
        --port 4648/tcp \
        --port 4648/udp \
        --shell "/bin/bash -E" \
        --user ${OCI_USER} \
        --volume "/nomad/data" \
        --workingdir "/home/${OCI_USER}" \
        ${OCI_NAME}

# Expose the nomad data directory as a volume since there's mutable state in there.
# --volume /nomad/data

# Server RPC is used for internal RPC communication between agents and servers,
# and for inter-server traffic for the consensus algorithm (raft).
#--port 4647/tcp

# Serf is used as the gossip protocol for cluster membership. Both TCP and UDP
# should be routable between the server nodes on this port.
#--port 4648/tcp 4648/udp

# HTTP is the primary interface that applications use to interact with Nomad.
#--port 4646/tcp

# Nomad doesn't need root privileges so we run it as the nomad user from the
# entry point script. 
#--entrypoint "nomad-entrypoint.sh"

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes HTTP endpoints, and bootstraps itself.  Don't use
# this configuration for production.
#--cmd "agent -dev"