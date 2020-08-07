#!/usr/bin/env bash

set -o errexit
set -o nounset

if [[ $DRONE_TAG =~ ^docker\- ]]; then
  echo "tag aimed at publishing helm chart; skipping docker image"
  exit 0
elif [[ $DRONE_TAG =~ ^helm\- ]]; then
  export HELM_TAG=${DRONE_TAG##helm-}
  echo helm tag is ${HELM_TAG}
else
  echo "only tags starting with 'docker-' or 'helm-' are supported; nothing published"
  exit 1
fi

cd helm

CHART_VERSION=$(yq r Chart.yaml version)

echo "Chart version is: ${CHART_VERSION}"
echo "Helm tag is: ${HELM_TAG}"

if [[ "${HELM_TAG}" != "${CHART_VERSION}" ]]; then
  echo "error: got helm tag of ${HELM_TAG} but was expecting same version as chart version (${CHART_VERSION})"
  exit 1
fi

echo "logging into ${HELM_REGISTRY} application registry"
helm quay login -u ${HELM_USERNAME} -p ${HELM_PASSWORD} ${HELM_REGISTRY}

echo "pushing chart to ${HELM_REGISTRY}/${HELM_REPO}"
helm quay push ${HELM_REGISTRY}/${HELM_REPO}
echo "done"
