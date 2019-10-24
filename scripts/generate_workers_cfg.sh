#!/bin/bash

TMPFILE=workers/temp.txt
TEMPLATE_BASE_FILE=workers/templates/base.yml
TARGET_FILE=workers/docker-compose.yml

touch ${TMPFILE}
for worker in "$@"
do
	TEMPLATE_FILE="workers/templates/${worker}.yml"
	if [ -f ${TEMPLATE_FILE} ]; then
    	cat ${TEMPLATE_FILE} >> ${TMPFILE}
    	echo " " >> ${TMPFILE}
    fi
done

cp ${TEMPLATE_BASE_FILE} ${TARGET_FILE}
sed -e '/##SERVICES##/ {' -e "r ${TMPFILE}" -e 'd' -e '}' -i ${TARGET_FILE}

rm ${TMPFILE}