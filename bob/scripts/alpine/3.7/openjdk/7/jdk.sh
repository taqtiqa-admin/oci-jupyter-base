#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - locale/us_utf8.sh

# If you're reading this and have any feedback to improve this script,
# please open an issue or a pull request so we can discuss it!
#
#   https://github.com/taqtiqa/bob/issues

#
# Modelled on:
# https://github.com/docker-library/openjdk/blob/17d0f9f3411d82622c762163d85cc4a6ba69af95/7-jdk/alpine/Dockerfile
#

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export JAVA_HOME=/usr/lib/jvm/java-1.7-openjdk" >> /etc/profile.d/openjdk-7-jdk.sh
echo "export PATH=$PATH:/usr/lib/jvm/java-1.7-openjdk/jre/bin:/usr/lib/jvm/java-1.7-openjdk/bin" >> /etc/profile.d/openjdk-7-jdk.sh
echo "export JAVA_VERSION=7u151" >>/etc/profile.d/openjdk-7-jdk.sh
echo "export JAVA_ALPINE_VERSION=7.151.2.6.11-r0" >> /etc/profile.d/openjdk-7-jdk.sh

for f in /etc/profile.d/*; do source $f; done

cat << EOF >/usr/local/bin/docker-java-home
#!/bin/sh
set -e
dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"
EOF
chmod +x /usr/local/bin/docker-java-home

set -x
apk add --no-cache openjdk7="$JAVA_ALPINE_VERSION"
[ "${JAVA_HOME}" = "$(docker-java-home)" ]