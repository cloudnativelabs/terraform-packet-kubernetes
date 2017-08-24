#!/usr/bin/env sh
set -e

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
TERRAFORM_OUTPUT="terraform output --state=${script_dir}/terraform.tfstate"
KUBE_VERSION="v$(eval "${TERRAFORM_OUTPUT} kube_version_patch")"
KUBECONFIG="$(eval "${TERRAFORM_OUTPUT} kubeconfig_path")"
export KUBECONFIG

# TODO: Download appropriate kubectl version if needed to match cluster
kubectl "${@}"
