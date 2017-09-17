#!/usr/bin/env sh
set -e

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
tf_dir="$(dirname ${script_dir})"
terraform_output="terraform output --state=${tf_dir}/terraform.tfstate"

# [ -z "${E2E_SKIP}" ] && E2E_SKIP="Disruptive|Kubectl"
[ -z "${E2E_SKIP}" ] && E2E_SKIP="(?i)\[k8s.io\] (Kubectl)|\[Disruptive\]|\[Experimental\]|\[HPA\]"
# [ -z "${E2E_FOCUS}" ] && E2E_FOCUS="Conformance"
[ -z "${E2E_FOCUS}" ] && E2E_FOCUS="(?i)(network|proxy|readiness probe|endpoint)|\[k8s.io\] services|(?i)\[k8s.io\] port forwarding|\[Conformance\]"
# [ -z "${E2E_PROVIDER}" ] && E2E_PROVIDER="local"
[ -z "${E2E_PROVIDER}" ] && E2E_PROVIDER=""
[ -z "${LOG_DUMP_SSH_KEY}" ] && LOG_DUMP_SSH_KEY="/pwd/assets/auth/id_rsa"
[ -z "${LOG_DUMP_SSH_USER}" ] && LOG_DUMP_SSH_USER="core"
[ -z "${KUBECONFIG}" ] && KUBECONFIG="${tf_dir}/assets/auth/kubeconfig"
[ -z "${KUBECTL}" ] && KUBECTL="/usr/local/bin/kubectl"
[ -z "${TEST_NAME}" ] && TEST_NAME="e2e"
[ -z "${KUBERNETES_CONFORMANCE_TEST}" ] && KUBERNETES_CONFORMANCE_TEST="y"
[ -z "${GINKGO_PARALLEL}" ] && GINKGO_PARALLEL="n"

if [ -z "${NODE_COUNT}" ]; then
    NODE_COUNT="$(eval "${terraform_output} node_public_ipv4" | wc -l)"
fi

if [ -z "${ADD_HOSTS}" ]; then
    ADD_HOSTS="$(eval "FORMAT=docker ${script_dir}/etc-hosts.sh")"
fi

for i in ${ADD_HOSTS}; do
    add_host_flag="${add_host_flag} --add-host=${i}"
done

echo "Focus argument: ${E2E_FOCUS}"
echo "Skip argument: ${E2E_SKIP}"

docker run \
    -v "${PWD}":/pwd \
    -v "${KUBECONFIG}":/kubeconfig \
    --workdir /pwd \
    --net=host \
    --rm \
    --env LOG_DUMP_SSH_USER \
    --env LOG_DUMP_SSH_KEY \
    --env KUBERNETES_CONFORMANCE_TEST \
    --env GINKGO_PARALLEL \
    ${add_host_flag} \
    quay.io/cloudnativelabs/kube-conformance:v1.7 \
        /usr/local/bin/e2e.test \
        --disable-log-dump="true" \
        --dump-logs-on-failure="false" \
        --repo-root="/kubernetes" \
        --ginkgo.skip="${E2E_SKIP}" \
        --ginkgo.focus="${E2E_FOCUS}" \
        --ginkgo.noColor="false" \
        --kubectl-path="${KUBECTL}" \
        --kubeconfig="/kubeconfig" \
        --provider="${E2E_PROVIDER}" \
        --num-nodes="${NODE_COUNT}" \
        "${@}"
