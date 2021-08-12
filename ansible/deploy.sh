#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
SCRIPT_NAME=`basename $0`

cd ${SCRIPT_DIR}

function print_usage () {
    echo "Usage: ${SCRIPT_NAME} INVENTORY HOST_GROUP"
    echo ""
    echo "INVENTORY is a inventory to deploy."
    echo "HOST_GROUP is a host group of ansible."
}

INVENTORY=$1
if [ -z ${INVENTORY} ]; then
    print_usage
    exit 1
elif [ ${INVENTORY} == "production" ]; then
    read -p "You'll deploy to production. Ok? (y/N): " PRODUCTION_SELECTED
    case "${PRODUCTION_SELECTED}" in
        [yY]*)
            ;;
        *)
            echo "Abort."
            exit 0
            ;;
    esac
fi

HOST_GROUP=$2
if [ -z ${HOST_GROUP} ]; then
    print_usage
    exit 1
fi

PLAYBOOK="${HOST_GROUP}.yml"
if [ ! -f ${PLAYBOOK} ]; then
    echo "Unknown host group: ${HOST_GROUP}"
    exit 1
fi

ansible-playbook -i ${INVENTORY} --ask-become-pass ${PLAYBOOK}
