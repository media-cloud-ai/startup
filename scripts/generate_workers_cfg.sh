#!/bin/bash

TARGET_FILE=workers/docker-compose.yml
EFK_FLAG=false

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

if [ $# -ge 2 ]; then
  if [ "$2" = "-EFK" ]; then
    EFK_FLAG=true
  fi
fi

displayworker() {
    echo "--> ${1} (${2})"
}


COMPOSITION="--- \n"
# keep this version for GPU support of runtime flag, upper version are bugged
COMPOSITION+="version: \"2.4\"\n\n"
COMPOSITION+="services:\n"

add_section() {
    COMPOSITION+="        "$1":\n";
}

depth() {
    for i in $(seq "$1"); do
      COMPOSITION+="  ";
    done
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
        count=1
        if [ $(_jq '.count!=null') = "true" ]; then
            count=$(_jq '.count')
        fi

        displayworker $(_jq '.name') $count

        for index in $(seq 1 $count); do
            COMPOSITION+="    "$(_jq '.name')"_"$index":\n";

            if [ $2 == "dev" ]; then
              add_section_with_value network_mode host
            fi

            if [ $(_jq '.image') != null ]; then
              add_section_with_value image $(_jq '.image')
            elif [ $(_jq '.build') != null ]; then
              add_section_with_value build $(_jq '.build')
            else
              echo "WARNING : No image nor build were given !"
            fi

            if [ $(_jq '.gpu') = "true" ]; then
                add_section_with_value runtime nvidia
            fi

            add_section volumes
            #add_item \${SHARED_WORK_DIRECTORY}:/data
            shared_volumes=$(echo ${SHARED_WORK_DIRECTORIES} | tr ";" "\n")
            for shared_volume in $shared_volumes
            do
                add_item ${shared_volume}
            done

            add_section environment
            add_string_env_var AMQP_QUEUE job_$(_jq '.name')
            add_string_env_var RUST_LOG info
            add_env_var AMQP_HOSTNAME
            add_env_var AMQP_PORT
            add_env_var AMQP_MANAGEMENT_PORT
            add_env_var AMQP_USERNAME
            add_env_var AMQP_PASSWORD
            add_env_var AMQP_VIRTUAL_HOST
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

            if [ $2 = "startup" ]; then
              add_section networks
              add_item mediacloudai_global
              add_item workers
            fi

            if [ $EFK_FLAG = true ]; then
              add_section logging
              depth 1; add_section_with_value driver "fluentd"
              depth 1; add_section options
              depth 2; add_section_with_value fluentd-address "localhost:24224"
              depth 2; add_section_with_value tag "$(_jq '.name').log"

              add_section depends_on
              add_item "fluentd"
            fi

            COMPOSITION+="\n";
        done
    done
}

generate_workers ./opensource.workers $1

PRIVATE_WORKERS_FILENAME=./private.workers
if test -f "$PRIVATE_WORKERS_FILENAME"; then
    generate_workers $PRIVATE_WORKERS_FILENAME $1
fi

if [ $EFK_FLAG = true ]; then
  COMPOSITION+="    fluentd:\n"
  COMPOSITION+="      build: ../fluentd\n"
  COMPOSITION+="      volumes:\n"
  COMPOSITION+="        - ../fluentd/conf:/fluentd/etc\n"
  COMPOSITION+="      ports:\n"
  COMPOSITION+="        - 24224:24224\n"
  COMPOSITION+="        - 24224:24224/udp\n"
  COMPOSITION+="      networks:\n"
  COMPOSITION+="        - mediacloudai_global\n\n"
fi

COMPOSITION+="networks:\n"
COMPOSITION+="    workers:\n"
COMPOSITION+="        driver: bridge\n"
COMPOSITION+="    mediacloudai_global:\n"
COMPOSITION+="        external: true\n"


echo -e "${COMPOSITION}" > $TARGET_FILE
