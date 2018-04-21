#!/usr/bin/env sh

#
# No requires
#
echo "############################################"
echo "##"
echo "## Bob: ${0}"
echo "##"
echo "############################################"

#
# Cleanup
#
rm -f /home/bob
rm -f /etc/profile.d/bob.sh
rm -f "/root/.wget-hsts"
apk del --purge .build-dependencies
rm -rf /var/cache/apk/*
unset HISTFILE
rm -f /root/.sh_history
rm -f /home/${OCI_USER}/.sh_history
#
# Clobber log files and /tmp
#
cd /
find /var/log -type f | while read f; do echo -ne '' > $f; done;
rm -rf /tmp
mkdir /tmp
rm -rf /var/cache/distfiles