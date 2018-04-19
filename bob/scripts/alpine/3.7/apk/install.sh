#!/usr/bin/env sh

# Requires
#   
#   setup.sh
#   sudo/install.sh
#   user/install.sh ${USER_NAME}

echo 'http://dl-cdn.alpinelinux.org/alpine/v3.7/main' >/etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/v3.7/community' >>/etc/apk/repositories
apk update
