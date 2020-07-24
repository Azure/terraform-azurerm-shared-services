#!/bin/bash

set -ex

if [ -z ${DOCKER_REGISTRY_URL+x} ]; then
    echo "DOCKER_REGISTRY_URL is required"
    exit 1
fi
if [ -z ${DOCKER_IMAGE_NAME+x} ]; then
    echo "DOCKER_IMAGE_NAME is required"
    exit 1
fi
if [ -z ${DOCKERFILE_PATH+x} ]; then
    echo "DOCKERFILE_PATH is required"
    exit 1
fi

# Only build if .devcontainer has changed
#
if [[ ! -z $(git diff @~..@ .devcontainer/) || ! -z $DOCKER_FIRST_BUILD ]]; then
  DOCKER_IMAGE_TAG=$(git rev-parse --short HEAD)
  DOCKER_IMAGE="${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}"
  DOCKER_IMAGE_WITH_TAG="${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}"
  DOCKER_IMAGE_LATEST="${DOCKER_IMAGE}:latest"

  echo "Building ${DOCKER_IMAGE}"
  docker build -t "${DOCKER_IMAGE_WITH_TAG}" -f "${DOCKERFILE_PATH}" .

  # If main/master or ./devcontainer/force_push changed then publish
  #
  if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' || ! -z $(git diff @~..@ .devcontainer/force_push) || ! -z $DOCKET_FIRST_BUILD ]]; then
    echo "Publishing ${DOCKER_IMAGE}"
    docker push "${DOCKER_IMAGE_WITH_TAG}"
    docker tag "${DOCKER_IMAGE_WITH_TAG}" "${DOCKER_IMAGE_LATEST}"
    docker push "${DOCKER_IMAGE_LATEST}"
  else
    echo "Not a main branch build, not publishing latest"
  fi

else
  echo "No changes detected in .devcontainer, skipping build"
fi



