#!/usr/bin/env sh
#
# Requires
#
# - setup.sh
# - sudo/install.sh
# - user/install.sh ${OCI_USER}
# - aports/install.sh

for f in /etc/profile.d/*; do source $f; done

alpine_aports_user=${OCI_USER:-bob}

##
## NOTE aports/install.sh is where the package folder 
##        tmp/aports/community/ 
##      is determined 
##

##
# Copy APKBUILD.texlive into local repo
pkg_name=texlive
pkg_dir=tmp/aports/community/${pkg_name}
mkdir -p ${pkg_dir}
src=/bob/aports/artifacts/${pkg_name}/APKBUILD.${pkg_name}
dst=/${pkg_dir}/APKBUILD
su - ${alpine_aports_user} -c "cp ${src} ${dst}"
su - ${alpine_aports_user} -c "cd /${pkg_dir} && abuild checksum"
su - ${alpine_aports_user} -c "cd /${pkg_dir} && abuild -r"

##
# Copy APKBUILD.texmf-dist into local repo
pkg_name=texmf-dist
pkg_dir=tmp/aports/community/${pkg_name}
mkdir -p ${pkg_dir}
src=/bob/aports/artifacts/${pkg_name}/APKBUILD.${pkg_name}
dst=/${pkg_dir}/APKBUILD
su - ${alpine_aports_user} -c "cp ${src} ${dst}"
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild checksum"
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild -r"

# Install built package
pkg_name=texlive-full
pkg_ver=20170524-r5
apk add /tmp/packages/community/x86_64/${pkg_name}-${pkg_ver}.apk

#
# Test build
#
su - ${alpine_aports_user} -c "pdflatex -output-format=pdf /bob/texlive/artifacts/texlive-check.tex"
