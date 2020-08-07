#!/usr/bin/env bash

set -o errexit
set -o nounset

if [[ $DRONE_TAG =~ ^docker\- ]]; then
  export DOCKER_TAG=${DRONE_TAG##docker-}
  echo docker tag is ${DOCKER_TAG}
elif [[ $DRONE_TAG =~ ^helm\- ]]; then
  echo "tag aimed at publishing docker image; skipping chart publication"
  exit 0
else
  echo "only tags starting with 'docker-' or 'helm-' are supported; nothing published"
  exit 1
fi

docker login -u="${DOCKER_USERNAME}" -p=${DOCKER_PASSWORD} ${DOCKER_REGISTRY}
docker tag ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DRONE_COMMIT_SHA} ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG}
docker push ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DRONE_COMMIT_SHA}
docker push ${DOCKER_REGISTRY}/${DOCKER_REPO}:${DOCKER_TAG}

echo done
