#!/usr/bin/env sh

# No Requires 

apk add --no-cache --virtual .build-dependencies alpine-sdk libarchive-tools
curl -Lsf 'https://github.com/jgm/pandoc/releases/download/1.17.2/pandoc-1.17.2-1-amd64.deb' \
    | bsdtar xOf - data.tar.gz \
    | tar xvz --strip-components 2 -C /usr/local
# apk del --purge .build-dependencies
