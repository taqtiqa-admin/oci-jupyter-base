#!/usr/bin/env sh

# No Requires

for f in /etc/profile.d/*; do source $f; done

OCI_USER=${OCI_USER:-bob}
user_name=${1:-$OCI_USER}

adduser -h /home/${user_name} -G 'wheel' -S -s /bin/ash ${user_name}
passwd -d ${user_name}
passwd ${user_name}<<EOF
${user_name}${user_name}
${user_name}${user_name}
EOF