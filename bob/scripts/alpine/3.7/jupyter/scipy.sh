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

#
# Load required env variables: build is in OCI/ACI shell session
#

echo "export XDG_CACHE_HOME=/home/${OCI_USER}/.cache/" > /etc/profile.d/jupyter-scipy.sh
echo "export MPLBACKEND=Agg" >> /etc/profile.d/jupyter-scipy.sh

for f in /etc/profile.d/*; do source $f; done

apk update
apk add --virtual .build-dependencies --no-cache alpine-sdk

## NOTE: 
# Upstream/ubuntu builds use libav-tools for matplotlib animation.
# libav does not build with muslc, see here[1] for lack of progress
# on the reported issue.
# Debian in 2015 reverted to ffmeg to replace libav, which had forked from ffmgeg.
# See here[2] for some detail.
#
# [1]: https://lists.libav.org/pipermail/libav-bugs/2016-March/004709.html
# [2]: https://lwn.net/Articles/650816/
apk add --no-cache ffmpeg

conda install --quiet --yes \
    'blas=*=openblas' \
    'ipywidgets=7.1*' \
    'pandas=0.19*' \
    'numexpr=2.6*' \
    'matplotlib=2.0*' \
    'scipy=0.19*' \
    'seaborn=0.7*' \
    'scikit-learn=0.18*' \
    'scikit-image=0.12*' \
    'sympy=1.0*' \
    'cython=0.25*' \
    'patsy=0.4*' \
    'statsmodels=0.8*' \
    'cloudpickle=0.2*' \
    'dill=0.2*' \
    'numba=0.31*' \
    'bokeh=0.12*' \
    'sqlalchemy=1.1*' \
    'hdf5=1.8.17' \
    'h5py=2.6*' \
    'vincent=0.4.*' \
    'beautifulsoup4=4.5.*' \
    'protobuf=3.*' \
    'xlrd'
conda remove --quiet --yes --force qt pyqt 
conda clean -tipsy

# Activate ipywidgets extension in the environment that runs the notebook server
jupyter nbextension enable --py widgetsnbextension --sys-prefix

# Also activate ipywidgets extension for JupyterLab
jupyter labextension install @jupyter-widgets/jupyterlab-manager@^0.33.1
jupyter labextension install jupyterlab_bokeh@^0.4.0
npm cache clean
rm -rf $CONDA_DIR/share/jupyter/lab/staging
rm -rf /home/$NB_USER/.cache/yarn
rm -rf /home/$NB_USER/.node-gyp

# Install facets which does not have a pip or conda package at the moment
cd /tmp
git clone https://github.com/PAIR-code/facets.git
cd facets
jupyter nbextension install facets-dist/ --sys-prefix
rm -rf facets

# Import matplotlib the first time to build the font cache.
python -c "import matplotlib.pyplot"
