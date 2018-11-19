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

    json="{\n \"hosts\": [\n"
    meta=$(echo "  \"_meta\": {\n    \"hostvars\": {\n")

    # Получаем список всех инстансов из google compute в формате "<имя> <ip>"
    list=$(gcloud compute instances list --format="table[no-heading](name, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)")
    # В цикле разбираем строку на имя и айпи и заполняем json
    while read -r line; do
        host=$(echo "$line" | awk '{print $1}')
        ip=$(echo "$line" | awk '{print $2}')
        json=$(echo "${json}     \"${host}\",\n")
        meta=$(echo "${meta}      \"${host}\": {\n        \"ansible_host\": \"${ip}\"\n      },\n")
    done <<< "$list"

    # Финальный штрих - избавляемся от лишних символов, закрываем json
    meta=$(echo "${meta}" | sed 's/,\\n$//g')
    meta=$(echo "${meta}\n    }\n  }")
    json=$(echo "${json}" | sed 's/,\\n$//g')
    json=$(echo "${json}\n  ],\n${meta}")
    json=$(echo "${json}\n}")
    
    echo -e "$json" > inventory_full_auto.json
    cat inventory_full_auto.json
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            shift 2
            getList
            ;;
        --host)
            shift 2
            echo '{"_meta": {"hostvars": {}}}'
            ;;
        *)
            break
            ;;
    esac
done
