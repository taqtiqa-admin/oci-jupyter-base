set -e
mruby_build_deps="bison ca-certificates gcc git libc6-dev libc-dev libhiredis-dev libssl-dev make pkgconfig ruby"
mruby_version='1.3.0'

apk update
# Install mruby build dependencies
apk add --virtual .build-dependencies --no-cache $mruby_build_deps


        
apk del .build-dependencies 
rm -rf /var/cache/apk/*

cp build_config.rb /build_config.rb
git clone https://github.com/mruby/mruby.git
mv -f /build_config.rb /mruby/build_config.rb
cd mruby
make -j$(nproc)


#!/bin/bash



# Download & build mruby
cd /tmp
mkdir -p /usr/local/mruby
curl https://codeload.github.com/mruby/mruby/tar.gz/$MRUBY_VERSION | tar xvz
cd /tmp/mruby-$MRUBY_VERSION
cp /tmp/build_config.rb ./
./minirake

# Move mruby and add links in /usr/local
mv build/host/* /usr/local/mruby/
ln -s /usr/local/mruby/bin/* /usr/local/bin/

# Clean up to keep container image small
apk del $BUILD_DEPS
cd /
rm -rf /tmp/mruby-$MRUBY_VERSION /var/cache/apk/*
rm -rf /usr/local/mruby/{lib,src}