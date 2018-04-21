#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - locale/us_utf8.sh

#
# Environment variables for the OCI/ACI context
#
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

#
# Environment variables for the Buildah context
#
ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" 
ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0"
ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk"
ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk"
ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk"

#
# Load required env variables: build is in OCI/ACI shell session
#
for f in /etc/profile.d/*; do source $f; done

sed -i 's/#unicode="NO"/unicode="YES"/g' /etc/rc.conf

cd /tmp 
apk add --no-cache --virtual=.build-dependencies wget ca-certificates
wget "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
      -O "/etc/apk/keys/sgerrand.rsa.pub" 
wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" 
apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"
/usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib
rm "/etc/apk/keys/sgerrand.rsa.pub"
# NOTE: $LANG is set in locale/*sh scripts
/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true
apk del glibc-i18n 
rm "/root/.wget-hsts"
apk del .build-dependencies 
rm -rf /var/cache/apk/*
rm "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# 
# libstdc++.so.6.0.21 is a Bob artifact
# Required by nodejs,kibana

ln -s /usr/lib/libstdc++.so.6.0.21 /usr/lib/libstdc++.so.6.new 
mv /usr/lib/libstdc++.so.6.new /usr/lib/libstdc++.so.6
