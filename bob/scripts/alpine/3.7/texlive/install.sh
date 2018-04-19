#!/usr/bin/env sh
#
# Requires
#
# - aports/install.sh

alpine_aports_user=${OCI_USER:-bob}

pkg_name=texmf-dist
pkg_dir=/tmp/aports/community/$pkg_name 
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild checksum"
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild -r"

pkg_name=texlive
pkg_dir=/tmp/aports/community/$pkg_name 
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild checksum"
su - ${alpine_aports_user} -c "cd ${pkg_dir} && abuild -r"

# Install built package
pkg_name=texlive-full
pkg_ver=20170524-r5
apk add /tmp/packages/community/x86_64/$pkg_name-$pkg_ver.apk

#
# Test build
#
cd /tmp
cat <<EOF >texlive-check.tex
\documentclass{article}
\usepackage[american]{babel}
\usepackage{blindtext}
\begin{document}
\blindmathtrue
\Blinddocument
\end{document}
EOF
su - ${alpine_aports_user} -c "cd /tmp && pdflatex -output-format=pdf texlive-check.tex"
