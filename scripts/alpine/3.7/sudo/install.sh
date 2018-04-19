#!/usr/bin/env sh
apk add --no-cache sudo
cat <<EOF > /etc/sudoers
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF