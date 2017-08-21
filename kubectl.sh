#!/usr/bin/env sh
set -e

KUBE_VERSION="v$(terraform output kube_version_patch)"
API_IP=$(terraform output api_ip)
KUBECONFIG=$(terraform output kubeconfig_path)

# TODO: Download appropriate kubectl version if needed to match cluster
kubectl --server="https://${API_IP}" "${@}"
