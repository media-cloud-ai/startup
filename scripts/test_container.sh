#!/bin/bash

if [ $# -eq 1 ]; then
    service=$1
else
    exit 1
fi

hostname="$(printenv ${service}_HOSTNAME)"
port="$(printenv ${service}_PORT)"
ping -q -c1 ${hostname} > /dev/null 2>/dev/null

exit $?
