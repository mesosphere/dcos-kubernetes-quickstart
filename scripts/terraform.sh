#!/bin/bash

set -e

ROOT=$(git rev-parse --show-toplevel)

TARGET_DIR="${ROOT}/.deploy"

CLOUD_PLATFORM="${1:-gcp}"

ACTION="${2:-init}"

case "${CLOUD_PLATFORM}" in
    "gcp")
        for var in GOOGLE_APPLICATION_CREDENTIALS GOOGLE_REGION GOOGLE_PROJECT GOOGLE_SSH_PUBLIC_KEY_FILE;
        do
            if [[ -z "${!var}" ]];
            then
                echo "${var} must be set"
                exit 1
            fi
        done
        ;;
    *)
        echo "\"$1\" is not a supported cloud provider"
        exit 1
        ;;
esac

case "${ACTION}" in
    "apply")
        cd "${TARGET_DIR}"
        terraform apply
        ;;
    "init")
        mkdir -p "${TARGET_DIR}"
        cd "${TARGET_DIR}"
        sed "s|__GCP_SSH_PUBLIC_KEY_FILE__|${GOOGLE_SSH_PUBLIC_KEY_FILE}|g; s|__USERNAME__|$(whoami)|g" "${ROOT}/resources/main.gcp.tf" > "${PWD}/main.tf"
        terraform init
        cp "${ROOT}/resources/options.json.gcp" "${PWD}/options.json"
        # TODO: Understand if we still need to run "kubeapi-proxy-gcp.sh".
        ;;
    *)
        echo "\"$1\" is not a supported action"
        exit 1
        ;;
esac
