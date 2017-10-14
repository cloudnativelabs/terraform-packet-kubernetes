#!/bin/bash
# Wrapper for bootkube start
set -e
# Move experimental manifests
[ -n "$(ls -d /opt/bootkube/assets/manifests-*)" ] && mv /opt/bootkube/assets/manifests-*/* /opt/bootkube/assets/manifests && rm -rf /opt/bootkube/assets/manifests-*
[ -d /opt/bootkube/assets/experimental/manifests ] && mv /opt/bootkube/assets/experimental/manifests/* /opt/bootkube/assets/manifests && rm -r /opt/bootkube/assets/experimental/manifests
[ -d /opt/bootkube/assets/experimental/bootstrap-manifests ] && mv /opt/bootkube/assets/experimental/bootstrap-manifests/* /opt/bootkube/assets/bootstrap-manifests && rm -r /opt/bootkube/assets/experimental/bootstrap-manifests
BOOTKUBE_ACI="${BOOTKUBE_ACI:-quay.io/coreos/bootkube}"
BOOTKUBE_VERSION="${BOOTKUBE_VERSION:-v0.6.2}"
BOOTKUBE_ASSETS="${BOOTKUBE_ASSETS:-/opt/bootkube/assets}"
exec /usr/bin/rkt run \
  --trust-keys-from-https \
  --volume assets,kind=host,source=$BOOTKUBE_ASSETS \
  --mount volume=assets,target=/assets \
  --volume bootstrap,kind=host,source=/etc/kubernetes \
  --mount volume=bootstrap,target=/etc/kubernetes \
  $RKT_OPTS \
  ${BOOTKUBE_ACI}:${BOOTKUBE_VERSION} \
  --net=host \
  --dns=host \
  --exec=/bootkube -- start --asset-dir=/assets "$@"
