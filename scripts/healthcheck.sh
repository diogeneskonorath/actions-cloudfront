#!/bin/bash

env=$1
retries=0
sleeping_time=1
status_code=0
timeout=5

case ${env} in
    dev)
        service_url=${HEALTHCHECK_DEV} ;;
    stg)
        service_url=${HEALTHCHECK_STG} ;;
    prd)
        service_url=${HEALTHCHECK_PRD} ;;
esac

echo "Iniciando Healthcheck no endpoint: ${service_url}"

while [ $retries -lt 10 ] && [ $status_code -ne 200 ]; do

    retries=$((retries+1));
    sleep $sleeping_time
    status_code=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout https://${service_url})

    echo "Status code: $status_code"

    sleeping_time=$((sleeping_time+sleeping_time));

done

if [ $status_code -eq 200 ]; then

    echo "Healthcheck realizado com sucesso. Status code: $status_code."
	echo ::set-output name=outLogs::"Healthcheck realizado com sucesso. Status code: $status_code."
    exit 0

else

    echo "Healthcheck realizado com erro. Status code: $status_code."
	echo ::set-output name=outLogs::"Healthcheck realizado com erro. Status code: $status_code."
    exit 1

fi