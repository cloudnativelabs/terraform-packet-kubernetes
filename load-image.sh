#!/usr/bin/env sh
set -ex

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
terraform_output="terraform output --state=${script_dir}/terraform.tfstate"
node_ips="$(eval "${terraform_output} node_public_ipv4")"
ssh_args="-i ${script_dir}/assets/auth/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

[ -z "${NODE_USER}" ] && NODE_USER="core"

print_usage() {
    echo
    echo "${0} uploads container images to your Kubernetes nodes and"
    echo "loads them into the rkt or docker store."
    echo
    echo "rkt images should have the suffix .aci"
    echo "docker images should have the suffix .docker"
    echo
    echo "Usage: ${0} IMAGE_FILE|IMAGE_DIR"
    echo
}

upload_image() {
    image_file="${1}"

    for node_ip in ${node_ips}; do
        ssh "${NODE_USER}@${node_ip}" "mkdir -p /var/tmp/images"
        rsync -avz \
            -e \
            "ssh ${ssh_args}" \
            "${image_file}" "${NODE_USER}@${node_ip}:/var/tmp/images/"
    done || return 1
    return 0
}

load_image() {
    image_path="$(dirname "${1}")"
    image_filename="$(basename "${1}")"
    image="${image_path}/${image_filename}"
    suffix="$(echo "${image_filename}" | sed -e 's/.*\././')"

    if [ "${suffix}" = ".aci" ]; then
        echo "INFO: Uploading ${image} to all nodes."
        upload_image "${image}" || exit 1
        echo "INFO: Loading ${image_filename} into all nodes' rkt image store"
        for node_ip in ${node_ips}; do
            ssh ${ssh_args} \
                "${NODE_USER}@${node_ip}" \
                "sudo rkt \
                    --insecure-options=image \
                    fetch /var/tmp/images/${image_filename}"
        done || exit 1
        return 0
    fi

    if [ "${suffix}" = ".docker" ]; then
        echo "INFO: Uploading ${image} to all nodes."
        upload_image "${image}" || exit 1
        echo "INFO: Loading ${image_filename} into all nodes' docker image store"
        for node_ip in ${node_ips}; do
            ssh ${ssh_args} \
                "${NODE_USER}@${node_ip}" \
                "docker load -i /var/tmp/images/${image_filename}"
        done || exit 1
        return 0
    fi

    echo "ERROR: File extension not recognized: ${1}"
    return 1
}

load_dir() {
    image_dir_path="${1}"

    for file in "${image_dir_path}"/*; do
        load_image "${file}"
    done
    return 0
}

if [ -z "${1}" ]; then
    echo "ERROR: No image file or directory provided."
    print_usage
    exit 1
fi

if [ -d "${1}" ]; then
    echo "INFO: Loading images from ${1}"
    load_dir "${1}"
    exit 0
fi

if [ -f "${1}" ]; then
    load_image "${1}"
    exit 0
fi

print_usage
exit 0
