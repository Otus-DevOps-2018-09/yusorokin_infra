#!/bin/bash

ARGUMENT_LIST=(
    "list"
    "host:"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --$opts

getList() {
    app_ip=""
    db_ip=""

    list=$(gcloud compute instances list --format="table[no-heading](name, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)")
    while read -r line; do
        host=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')
        if echo "$host" | grep app > /dev/null; then
            app_ip=$(echo "$ip")
        fi
        if echo "$host" | grep db > /dev/null; then
            db_ip=$(echo "$ip")
        fi 
    done <<< "$list"

    json="{\n"
    meta=$(echo "  \"_meta\": {\n    \"hostvars\": {\n")

    if [ "$app_ip" != "" ]; then
        json=$(echo "${json}  \"app\": {\n    \"hosts\": [\"appserver\"]\n  }")
        meta=$(echo "${meta}      \"appserver\": {\n        \"ansible_host\": \"$app_ip\"\n      }")
    fi

    if [ "$db_ip" != "" ]; then
        json=$(echo "${json},\n")
        json=$(echo "${json}  \"db\": {\n    \"hosts\": [\"dbserver\"]\n  }")
        meta=$(echo "${meta},\n")
        meta=$(echo "${meta}      \"dbserver\": {\n        \"ansible_host\": \"$db_ip\"\n      }")
    fi

    meta=$(echo "${meta}\n    }\n  }")
    json=$(echo "${json},\n${meta}")
    json=$(echo "${json}\n}")
    echo -e "$json" > inventory.json
    cat inventory.json
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            shift 2
            getList
            ;;

        --host)
            argTwo=$2
            shift 2
            echo '{"_meta": {"hostvars": {}}}'
            ;;
        *)
            break
            ;;
    esac
done
