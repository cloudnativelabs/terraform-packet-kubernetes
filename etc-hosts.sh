#!/usr/bin/env sh
set -e

if [ "$(id -u)" = 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

[ -z "$HOSTS_FILE" ] && HOSTS_FILE="/etc/hosts"

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
terraform_output="terraform output --state=${script_dir}/terraform.tfstate"
hosts_entry="$(eval "${terraform_output} hosts_file_entries | head -n1")"
api_hostname="$(eval "${terraform_output} api_hostname")"

# Sanity check
echo "${api_hostname}" | grep -Fq controller
if [ "${?}" != 0 ]; then
    echo "ERROR: \"terraform output api_hostname\" does not contain \"controller\"."
    echo "Aborting."
    exit 1
fi

if grep -F "${api_hostname}" "${HOSTS_FILE}"; then
    echo "INFO: Removing above host file entry."
    "${SUDO}" sed -i "/${api_hostname}/d" "${HOSTS_FILE}"
else
    echo "INFO: ${api_hostname} not found in hosts file."
fi

echo "INFO: Appending the following host entry to your hosts file."
echo "${hosts_entry}" | "${SUDO}" tee -a "${HOSTS_FILE}"
