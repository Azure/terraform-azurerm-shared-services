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

if [[ ! -z $(git diff @~..@ .devcontainer/) ]]; then
  # Only build if devcontainer dir has changed
  BUILD_REQUIRED=true
fi

if [[ $(git rev-parse --abbrev-ref HEAD) == 'master' || ! -z $(git diff @~..@ .devcontainer/force_push) ]]; then
  # Only push if we're on master or user is forcing a push from a branch
  PUSH_REQUIRED=true
fi

DOCKER_IMAGE_TAG=$(git rev-parse --short HEAD)
DOCKER_IMAGE="${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}"
DOCKER_IMAGE_WITH_TAG="${DOCKER_IMAGE}:${DOCKER_IMAGE_TAG}"
DOCKER_IMAGE_LATEST="${DOCKER_IMAGE}:latest"

# If image doesn't exist, force build and push
docker pull "${DOCKER_IMAGE_LATEST}"
if [[ ! $? = 0 ]]; then
  BUILD_REQUIRED=true
  PUSH_REQUIRED=true
fi

if [[ $BUILD_REQUIRED = true ]]; then

  echo "Building ${DOCKER_IMAGE}"
  docker build -t "${DOCKER_IMAGE_WITH_TAG}" -f "${DOCKERFILE_PATH}" .

  if [[ $PUSH_REQUIRED = true ]]; then
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



