#!/bin/bash

TARGET_FILE=workers/docker-compose.yml

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

COMPOSITION="--- \n"
# keep this version for GPU support of runtime flag, upper version are bugged
COMPOSITION+="version: \"2.4\"\n\n"
COMPOSITION+="services:\n"

add_section() {
    COMPOSITION+="        "$1":\n";
}

add_section_with_value() {
    COMPOSITION+="        "$1": "$2"\n";
}

add_env_var() {
    COMPOSITION+="            "$1": \"\${"$1"}\"\n"
}

add_string_env_var() {
    COMPOSITION+="            "$1": \""$2"\"\n"
}

add_custom_env_var() {
    COMPOSITION+="            "$1": "$2"\n"
}

add_extra_env_var() {
    COMPOSITION+="            $1\n"
}

add_item() {
    COMPOSITION+="            - "$1"\n";
}

generate_workers () {
    for row in $(jq -r '.[] | @base64' $1); do
        _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
        }

        COMPOSITION+="    "$(_jq '.name')":\n";
        # COMPOSITION+="        image: "$(_jq '.image')"\n";
        add_section_with_value image $(_jq '.image')
       
        if [ $(_jq '.gpu') = "true" ]; then
            add_section_with_value runtime nvidia
        fi

        add_section volumes
        add_item \${SHARED_WORK_DIRECTORY}:/data

        add_section environment
        add_string_env_var AMQP_QUEUE job_$(_jq '.name')
        add_string_env_var RUST_LOG info
        add_env_var AMQP_HOSTNAME
        add_env_var AMQP_PORT
        add_env_var AMQP_MANAGEMENT_PORT
        add_env_var AMQP_USERNAME
        add_env_var AMQP_PASSWORD
        add_env_var AMQP_VHOST
        add_env_var AMQP_TLS

        if [ `echo ${row} | base64 --decode | jq '.environment!=null'` == true ]; then

            for extra_env in `echo ${row} | base64 --decode | jq '.environment[] | @base64'`; do
                _jq2() {
                    echo ${extra_env} | sed -e 's/^"//' -e 's/"$//' | base64 --decode | jq -r ${1}
                }

                add_custom_env_var $(_jq2 '.key') "\""$(_jq2 '.value')"\""
            done
        fi

        if [ $(_jq '.vault') = "true" ]; then
            add_custom_env_var BACKEND_HOSTNAME \"\${BACKEND_HOSTNAME}/api\"
            add_custom_env_var BACKEND_PASSWORD \"\${BACKEND_PASSWORD}\"
            add_custom_env_var BACKEND_USERNAME \"\${BACKEND_USERNAME}\"
        fi

        if [ $(_jq '.gpu') = "true" ]; then
            add_string_env_var NVIDIA_VISIBLE_DEVICES all
        fi
        add_section networks
        add_item mediacloudai_global
        add_item workers

        COMPOSITION+="\n";
    done
}

generate_workers ./opensource.workers

PRIVATE_WORKERS_FILENAME=./private.workers
if test -f "$PRIVATE_WORKERS_FILENAME"; then
    generate_workers $PRIVATE_WORKERS_FILENAME
fi

COMPOSITION+="networks:\n"
COMPOSITION+="    workers:\n"
COMPOSITION+="        driver: bridge\n"
COMPOSITION+="    mediacloudai_global:\n"
COMPOSITION+="        external: true\n"


echo -e "${COMPOSITION}" > $TARGET_FILE
