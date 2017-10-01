#!/usr/bin/env sh
set -e

if [ ! -d "${GOPATH}" ]; then
    echo "ERROR: GOPATH is not set up. Do you have a functional Go workspace?"
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"

if [ "${IN_DOCKER_CONTAINER}" != "1" ]; then
    docker pull golang:alpine
    docker run \
        --rm \
        -v "${script_dir}/$(basename ${0}):/get-providers.sh" \
        -v "${GOPATH}/bin:/go/bin" \
        -e "IN_DOCKER_CONTAINER=1" \
        golang:alpine \
        sh -c " \
            apk add -U git && \
            /get-providers.sh \
        "
    exit 0
fi

CGO_ENABLED=0
export CGO_ENABLED

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
    git_alias_date="$(date --utc -Iseconds)"
    for i in ${provider_go_urls}; do
        short_name="$(provider_short_name "${i}")"
        git_alias="$(eval 'echo ${'${short_name}'}')"
        go get -d "${i}"
        if [ -n "${git_alias}" ]; then
            echo "INFO: Using ${git_alias} as git alias for $(provider_full_name "${i}")"

            # if [ -d "$GOPATH/src/${i}" ]; then
            #     echo "INFO: Moving $GOPATH/src/${i} -> $GOPATH/src/${i}-${git_alias_date}"
            #     mv "$GOPATH/src/${i}" "$GOPATH/src/${i}-${git_alias_date}"
            # fi

            echo "INFO: Fetching alias git repo ${git_alias}"
            old_dir="${PWD}"
            cd "$GOPATH/src/${i}"
            git remote add alias_repo "${git_alias}"
            git fetch alias_repo
            git checkout -b alias_repo_master alias_repo/master
            go install
            cd "${old_dir}"
            # go get -d "${git_alias}"
            # ln -s "$GOPATH/src/${git_alias}" "$GOPATH/src/${i}"
            # old_dir="${PWD}"
            # cd "$GOPATH/src/${i}"
            # git pull
            # go install
            # cd "${old_dir}"
        fi

        # if [ -n "${git_alias}" ] && [ -d "$GOPATH/src/${i}-${git_alias_date}" ]; then
        #     echo "INFO: Restoring $GOPATH/src/${i}-${git_alias_date} to original location."
        #     unlink "$GOPATH/src/${i}"
        #     mv "$GOPATH/src/${i}-${git_alias_date}" "$GOPATH/src/${i}"
        # fi
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
# packet="github.com/cloudnativelabs/terraform-provider-packet"
packet="https://github.com/cloudnativelabs/terraform-provider-packet.git"
export packet

set_provider_vars \
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

echo "Done! Be sure you have the following in your ~/.terraformrc"
echo "${terraformrc}"
