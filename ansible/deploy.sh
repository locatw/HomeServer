#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
SCRIPT_NAME=`basename $0`

cd ${SCRIPT_DIR}

function print_usage () {
    echo "Usage: ${SCRIPT_NAME} HOST_GROUP"
    echo ""
    echo "HOST_GROUP is a host group of ansible."
}

HOST_GROUP=$1
if [ -z ${HOST_GROUP} ]; then
    print_usage
    exit 1
fi

PLAYBOOK="${HOST_GROUP}.yml"
if [ ! -f ${PLAYBOOK} ]; then
    echo "Unknown host group: ${HOST_GROUP}"
    exit 1
fi

ansible-playbook -i hosts --ask-become-pass ${PLAYBOOK}
