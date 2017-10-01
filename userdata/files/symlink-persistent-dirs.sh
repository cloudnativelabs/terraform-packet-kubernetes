#!/usr/bin/env sh
set -xe

MOVE_DIR="/moved"
DATA_DIR="/DATA"

[ -n "${PERSIST_DIRS}" ] || ( \
    echo "Error: No PERSIST_DIRS provided"
    exit 1)

mkdir -p "${MOVE_DIR}"

for dir in ${PERSIST_DIRS}; do
    DIR_NAME="$(basename "${dir}")"
    DEST_DIR="${MOVE_DIR}/${DIR_NAME}"

    if [ -d "${dir}" ] && [ ! -L "${dir}" ]
    then
        if [ -d "${DEST_DIR}" ]
        then
            cp -an "${dir}"/* "${DEST_DIR}"
        else
            mv "${dir}" "${DEST_DIR}"
        fi
    else
        if [ -L "${dir}" ]
        then
            continue
        else
            ln -s "${DATA_DIR}/${DIR_NAME}" "${dir}"
        fi
    fi
done
