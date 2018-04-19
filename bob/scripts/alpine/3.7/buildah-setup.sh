#!/usr/bin/env sh

# Requires
# - setup.sh

# Copy ${OCI_BASE_NAME}/${OCI_BASE_TAG} scripts and artifacts
${BUILDAH} copy ${OCI_NAME} \
                "./scripts/${OCI_BASE_NAME}/${OCI_BASE_TAG}/" \
                '/bob'


