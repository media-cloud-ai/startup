#!/bin/bash

TARGET_FILE=workers/docker-compose.yml
EFK_FLAG=false

if ! [ -x "$(command -v yq)" ]; then
  echo 'Error: yq is not installed.' >&2
  exit 1
fi

if [ $# -ge 4 ]; then
  if [ "$4" = "-EFK" ]; then
    EFK_FLAG=true
  fi
fi

displayworker() {
    echo "--> ${1} (${2})"
}

set -e

echo "---" > $TARGET_FILE

SHARED_WORK_DIRECTORIES=$2
LOG_LEVEL=$3

#####
# PREPARATION
#####

# Preparing common elements
TEMPLATE=$(yq -o=j workers/worker.yml.tpl)

# Shared directories
IFS=';' read -ra DIRS <<< "$SHARED_WORK_DIRECTORIES"
for DIR in "${DIRS[@]}"; do
  TEMP=$(echo $TEMPLATE | shared=$DIR yq -o=j '.worker.volumes += [env(shared)]')
  TEMPLATE=$TEMP
done

# Logging level
echo $TEMPLATE | log_level=$LOG_LEVEL yq -P '.worker.environment["RUST_LOG"] = env(log_level)' > workers/worker.yml


#####
# TEMPLATING
#####

TEMPLATE=$(yq -o=j workers/docker-compose.yml.tpl)

for WORKER_FILE in opensource.workers.yml private.workers.yml; do

  if test -f $WORKER_FILE; then

    SIZE=$(($(yq '.workers | length' $WORKER_FILE)-1))

    for WORKER in $(seq 0 1 $SIZE); do

      NAME=$(id=$WORKER yq '.workers[env(id)].name' opensource.workers.yml)
      REPLICAS=$(id=$WORKER yq '.workers[env(id)].count' opensource.workers.yml)
      IMAGE=$(id=$WORKER yq '.workers[env(id)].image' opensource.workers.yml)
      VAULT=$(id=$WORKER yq '.workers[env(id)].vault' opensource.workers.yml)
      CUSTOM_ENV=$(id=$WORKER yq -o=j '.workers[env(id)].environment' opensource.workers.yml)
      GPU=$(id=$WORKER yq '.workers[env(id)].gpu' opensource.workers.yml)

      displayworker $NAME $REPLICAS

      # Config per replica
      for REP_WORKER in $(seq 1 1 $REPLICAS); do
        REP_NAME=$NAME\_$REP_WORKER
        JOB="job_"$NAME
        TEMP=$(echo $TEMPLATE | worker_template=$(yq '.worker' workers/worker.yml) image=$IMAGE rep_name=$REP_NAME job=$JOB yq -o=j '.services[env(rep_name)].image = env(image) | .services[env(rep_name)] += env(worker_template) | .services[env(rep_name)].environment["AMQP_QUEUE"] = env(job)')
        TEMPLATE=$TEMP

        # Custom envvar case
        if [ "$CUSTOM_ENV" != "null" ]; then
          TEMP=$(echo $TEMPLATE | rep_name=$REP_NAME custom_env=$CUSTOM_ENV yq -o=j '.services[env(rep_name)].environment += env(custom_env)')
          TEMPLATE=$TEMP
        fi

        # Vault case
        if [ $VAULT = "true" ]; then
          TEMP=$(echo $TEMPLATE | rep_name=$REP_NAME host='${BACKEND_HOSTNAME}/api' pass='${BACKEND_PASSWORD}' user='${BACKEND_USERNAME}' yq -o=j '.services[env(rep_name)].environment["BACKEND_HOSTNAME"] = env(host) | .services[env(rep_name)].environment["BACKEND_PASSWORD"] = env(pass) | .services[env(rep_name)].environment["BACKEND_USERNAME"] = env(user)')
          TEMPLATE=$TEMP
        fi

        # GPU case
        if [ $GPU = "true" ]; then
          TEMP=$(echo $TEMPLATE | rep_name=$REP_NAME yq -o=j '.services[env(rep_name)].runtime = "nvidia"')
          TEMPLATE=$TEMP
        fi

        # Fluentd
        if [ $EFK_FLAG = true ]; then
          TEMP=$(echo $TEMPLATE | rep_name=$REP_NAME logging="$(yq '.logging' backend/fluentd.yml.tpl)" yq -o=j '.services[env(rep_name)].logging += env(logging) | .services[env(rep_name)].logging.options.tag = "workers.log"')
          TEMPLATE=$TEMP
        fi
      done
    done
  fi
done

echo $TEMPLATE | yq -P 'sort_keys(..)' >> $TARGET_FILE
echo "..." >> $TARGET_FILE

# Remove temp files
rm workers/worker.yml

set +e
