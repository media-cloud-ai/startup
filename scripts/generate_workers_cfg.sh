#!/bin/bash

TARGET_FILE=workers/docker-compose.yml

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

COMPOSITION="--- \n"
COMPOSITION+="version: \"3.6\"\n\n"
COMPOSITION+="services:\n"

add_section() {
    COMPOSITION+="\t\t"$1":\n";
}

add_env_var() {
    COMPOSITION+="\t\t\t"$1": \"\${"$1"}\"\n"
}

add_string_env_var() {
    COMPOSITION+="\t\t\t"$1": \""$2"\"\n"
}

add_custom_env_var() {
    COMPOSITION+="\t\t\t"$1": "$2"\n"
}

add_extra_env_var() {
    COMPOSITION+="\t\t\t$1\n"
}

add_item() {
    COMPOSITION+="\t\t\t- "$1"\n";
}

generate_workers () {
    for row in $(jq -r '.[] | @base64' $1); do
        _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
        }

        COMPOSITION+="\t"$(_jq '.name')":\n";
        COMPOSITION+="\t\timage: "$(_jq '.image')"\n";
       
        add_section volumes
        add_item \${PWD}/data:/data

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
            add_custom_env_var BACKEND_HOSTNAME \"\${BACKEND_PASSWORD}\"
            add_custom_env_var BACKEND_HOSTNAME \"\${BACKEND_EMAIL}\"
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
COMPOSITION+="\tworkers:\n"
COMPOSITION+="\t\tdriver: bridge\n"
COMPOSITION+="\tmediacloudai_global:\n"
COMPOSITION+="\t\texternal: true\n"


echo -e $COMPOSITION > $TARGET_FILE
