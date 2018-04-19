#!/usr/bin/env sh

# Requires:
#
# - setup.sh

lang=C.UTF-8
language=en_US.UTF-8
lc_all=en_US.UTF-8

echo "export LANG=${lang}" > /etc/profile.d/locale.sh
echo "export LANGUAGE=${language}" >> /etc/profile.d/locale.sh
echo "export LC_ALL=${lc_all}" >> /etc/profile.d/locale.sh
