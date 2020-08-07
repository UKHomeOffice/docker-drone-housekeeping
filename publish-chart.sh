#!/usr/bin/env bash

set -o errexit
set -o nounset

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
