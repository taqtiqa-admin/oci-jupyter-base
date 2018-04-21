#!/usr/bin/env sh

# Requires:
#
# - setup.sh
# - glibc/install.sh
# - miniconda3/install.sh

echo $(whoami)


#
# Load required env variables is case we are building 
# in the same shell session
#
echo "export NB_USER=${OCI_USER}" > /etc/profile.d/jupyter.sh
echo "export NB_GROUP=${OCI_USER_GROUP}" >> /etc/profile.d/jupyter.sh
echo "export NB_UID=${OCI_USER_ID}" >> /etc/profile.d/jupyter.sh
echo "export NB_GID=${OCI_USER_GROUP_ID}" >> /etc/profile.d/jupyter.sh
echo "export HOME=/home/${OCI_USER}" >> /etc/profile.d/jupyter.sh
echo "export SHELL=/bin/bash" >> /etc/profile.d/jupyter.sh

for f in /etc/profile.d/*; do source $f; done

apk update
apk upgrade 
apk add --no-cache bash shadow
apk add --virtual .build-dependencies --no-cache ca-certificates

useradd --create-home --shell /bin/bash --no-user-group --non-unique --uid ${OCI_USER_ID} ${OCI_USER}

chown ${OCI_USER}:${OCI_USER_GROUP} /home/${OCI_USER}
chmod -Rv 6755 /home/${OCI_USER}
chmod -Rv u=rwx,go=rwx,a+s /home/${OCI_USER}

chown ${OCI_USER}:${OCI_USER_GROUP} ${CONDA_DIR}
chmod -Rv 6755 ${CONDA_DIR}
chmod -Rv u=rwx,go=rwx,a+s ${CONDA_DIR}

chmod g+w /etc/passwd /etc/group 

# Install Jupyter Notebook, Lab and Hub
# Issue #589: Use tornado < 5.0 until zmq dependencies resolved upstream
mkdir -p /etc/jupyter
chown ${OCI_USER}:${OCI_USER_GROUP} /etc/jupyter
chmod -Rv 6755 /etc/jupyter
chmod -Rv u=rwx,go=rwx,a+s /etc/jupyter

conda install --quiet --yes \
              'notebook=5.4.*' \
              'jupyterhub=0.8.*' \
              'jupyterlab=0.31.*' \
              'tornado=4.*'
jupyter labextension install @jupyterlab/hub-extension@^0.8.0 

src=/bob/jupyter/artifacts/usr/local/bin
dest=/usr/local/bin
cp ${src}/start.sh ${dest}/start.sh
cp ${src}/start-singleuser.sh ${dest}/start-singleuser.sh
cp ${src}/start-notebook.sh ${dest}/start-notebook.sh
cp ${src}/jupyter_notebook_config.py ${dest}/jupyter_notebook_config.py

conda clean -tipsy
npm cache clean 
rm -rf ${CONDA_DIR}/share/jupyter/lab/staging
rm -rf /home/${OCI_USER}/.cache/yarn
