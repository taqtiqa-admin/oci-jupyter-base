#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - miniconda3/install.sh
# - jupyter/install.sh
# - pandoc/install.sh
# - aports/install.sh
# - jupyter/minimal.sh
# - jupyter/scipy.sh
# - jupyter/r.sh

julia_ver=0.6.2

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export JULIA_PKGDIR=/opt/julia" > /etc/profile.d/julia.sh
echo "export JULIA_VERSION=${julia_ver}" >> /etc/profile.d/julia.sh

for f in /etc/profile.d/*; do source $f; done

apk update
apk add --virtual .build-dependencies --no-cache alpine-sdk wget

# Julia dependencies
mkdir -p /opt/julia-${JULIA_VERSION}
cd /tmp
wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
echo "dc6ec0b13551ce78083a5849268b20684421d46a7ec46b17ec1fab88a5078580 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c -
tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1
rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia
echo "push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
mkdir ${JULIA_PKGDIR}
chown ${NB_USER} ${JULIA_PKGDIR}
fix-permissions ${JULIA_PKGDIR}

# Add Julia packages. 
# NOTE upstream skips adding HDF5. Reason:
# Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.

julia ./artifacts/julia_pkgs.jl

# move kernelspec out of home \
mv ${HOME}/.local/share/jupyter/kernels/julia* ${CONDA_DIR}/share/jupyter/kernels/
chmod -R go+rx ${CONDA_DIR}/share/jupyter
rm -rf ${HOME}/.local
