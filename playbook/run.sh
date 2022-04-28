#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

containers=("centos:7" "ubuntu" "fedora")

function cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

    for i in ${containers[@]}
    do
        docker ps -q --filter "name=${i//:/}" | grep -q . && echo -e "${RED}Cleanup ${i//:/}${NC}" && docker stop ${i//:/} >/dev/null && docker rm ${i//:/} >/dev/null || true
    done
}

for i in ${containers[@]}
do
    echo -e "${GREEN}Create container ${i//:/}${NC}" && docker run --name ${i//:/} -d pycontribs/$i sleep 10000000
done

ansible-playbook -i inventory/prod.yml site.yml 

cleanup
