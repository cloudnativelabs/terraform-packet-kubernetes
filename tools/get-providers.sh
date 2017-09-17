#!/usr/bin/env sh
set -e

if [ ! -d "${GOPATH}" ]; then
    echo "ERROR: GOPATH is not set up. Do you have a functional Go workspace?"
fi

set_provider_vars() {
    for i in ${@}; do
        provider_go_urls="${provider_go_urls} ${i}"
    done
}

provider_full_name() {
    basename "${1}"
}

provider_short_name() {
    provider_full_name "${1}" | \
        sed -e 's/terraform-provider-//'
}

print_providers() {
    for i in ${provider_go_urls}; do
        echo "${i} $(provider_full_name "${i}") $(provider_short_name "${i}")"
    done
}

go_get_providers() {
    git_alias_date="$(date --utc --iso-8601=seconds)"
    for i in ${provider_go_urls}; do
        short_name="$(provider_short_name "${i}")"
        git_alias="$(eval 'echo ${'${short_name}'}')"
        if [ -n "${git_alias}" ]; then
            echo "INFO: Using ${git_alias} as git alias for $(provider_full_name "${i}")"

            if [ -d "$GOPATH/src/${i}" ]; then
                echo "INFO: Moving $GOPATH/src/${i} -> $GOPATH/src/${i}-${git_alias_date}"
                mv "$GOPATH/src/${i}" "$GOPATH/src/${i}-${git_alias_date}"
            fi

            echo "INFO: Fetching alias git repo $GOPATH/src/${git_alias}"
            go get -d "${git_alias}"
            cp -r "$GOPATH/src/${git_alias}" "$GOPATH/src/${i}"
        fi

        go get -u "${i}"

        if [ -n "${git_alias}" ] && [ -d "$GOPATH/src/${i}-${git_alias_date}" ]; then
            echo "INFO: Restoring $GOPATH/src/${i}-${git_alias_date} to original location."
            rm -rf "$GOPATH/src/${i}"
            mv "$GOPATH/src/${i}-${git_alias_date}" "$GOPATH/src/${i}"
        fi
    done
}

print_terraformrc() {
    echo "providers {"
    for i in ${provider_go_urls}; do
        short_name="$(provider_short_name "${i}")"
        full_name="$(provider_full_name "${i}")"
        echo "  ${short_name} = \"\${GOPATH}/bin/${full_name}\""
    done
    echo "}"
}

### main ###

# Set provider git repo aliases
packet="github.com/cloudnativelabs/terraform-provider-packet"
export packet

set_provider_vars \
    "github.com/coreos/terraform-provider-ct" \
    "github.com/terraform-providers/terraform-provider-packet"

echo "INFO: ${0} will install the following Terraform providers:"
print_providers
echo

echo "INFO: Fetching and compiling Terraform providers."
go_get_providers
echo

echo "INFO: Generating .terraformrc content."
terraformrc="$(print_terraformrc)"
echo

# backup_date="$(date --utc --iso-8601=seconds)"
# if [ -e "${HOME}/.terraformrc" ]; then
#     if [ "${terraformrc}" = "$(cat "${HOME}/.terraformrc")" ]; then
#         echo "INFO: ${HOME}/.terraformrc already looks good! Exiting."
#         exit 0
#     else
#         echo "INFO: Backing up existing .terraformrc to ${HOME}/.terraformrc-${backup_date}"
#         if [ -f "${HOME}/.terraformrc" ]; then
#             mv "${HOME}/.terraformrc" "${HOME}/.terraformrc-${backup_date}"
#             echo
#         else
#             echo "ERROR: Backup failed. ${HOME}/.terraformrc is not a file?"
#             exit 1
#         fi
#     fi
# fi

echo "Done! Be sure you have the following in your ~/.terraformrc"
echo "${terraformrc}"
