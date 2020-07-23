#!/bin/bash

set -e

if [ -z ${DOCKER_REGISTRY_URL+x} ]; then
    echo "DOCKER_REGISTRY_URL is required"
    exit 1
fi
if [ -z ${DOCKER_IMAGE_NAME+x} ]; then
    echo "DOCKER_IMAGE_NAME is required"
    exit 1
fi
if [ -z ${DOCKER_IMAGE_TAG+x} ]; then
    echo "DOCKER_IMAGE_TAG is required"
    exit 1
fi
if [ -z ${DOCKERFILE_PATH+x} ]; then
    echo "DOCKERFILE_PATH is required"
    exit 1
fi

DOCKER_IMAGE="${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}"
DOCKER_IMAGE_WITH_TAG="${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}${DOCKER_IMAGE_TAG_EXT}"
DOCKER_IMAGE_LATEST="${DOCKER_IMAGE}:latest"

echo "Building ${DOCKER_IMAGE}"
docker build -t "${DOCKER_IMAGE_WITH_TAG}" -f "${DOCKERFILE_PATH}" .

echo "Publishing ${DOCKER_IMAGE}"
docker push "${DOCKER_IMAGE_WITH_TAG}"
docker tag "${DOCKER_IMAGE_WITH_TAG}" "${DOCKER_IMAGE_LATEST}"
docker push "${DOCKER_IMAGE_LATEST}"
