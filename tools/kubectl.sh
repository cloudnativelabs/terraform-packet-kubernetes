#!/usr/bin/env sh
set -e

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
tf_dir="$(dirname ${script_dir})"
terraform_output="terraform output --state=${tf_dir}/terraform.tfstate"
KUBE_VERSION="v$(eval "${terraform_output} kube_version_patch")"
KUBECONFIG="$(eval "${terraform_output} kubeconfig_path")"
export KUBECONFIG

# TODO: Download appropriate kubectl version if needed to match cluster
kubectl "${@}"
