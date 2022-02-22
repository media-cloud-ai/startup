#!/bin/bash

TARGET_FILE=backend/docker-compose.yml
EFK_FLAG=false

if ! [ -x "$(command -v yq)" ]; then
  echo 'Error: yq is not installed.' >&2
  exit 1
fi

if [ $# -ge 2 ]; then
  if [ "$2" = "-EFK" ]; then
    EFK_FLAG=true
  fi
fi

set -e

if [ $EFK_FLAG = true ]; then
  fluentd="$(yq '.fluentd' backend/fluentd.yml.tpl)" logging="$(yq '.logging' backend/fluentd.yml.tpl)" yq '.services["fluentd"] += env(fluentd) | .services["backend"].depends_on += "fluentd" | .services["backend"].logging += env(logging)' backend/docker-compose.yml.tpl > $TARGET_FILE
else
  yq backend/docker-compose.yml.tpl > $TARGET_FILE
fi

set +e
