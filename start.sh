#!/bin/bash


couchbase_nodes=("couchbase1" "couchbase2" "couchbase3")

echo "======================================================"

for node in "${couchbase_nodes[@]}"
do
	echo Starting $node
    docker-compose up -d $node
done

echo "======================================================"

for node in "${couchbase_nodes[@]}"
do
	echo Healthcheck of ${node}
    container_id=$(docker-compose ps -q ${node})
    i=1
    while [ "$i" -ne 0 ]
    do
        status=$(docker inspect --format='{{.State.Health.Status}}' ${container_id})
        if [ "${status}" == "healthy" ]; then
            i=0
        fi
        echo Container ${node} id ${container_id} status is ${status}
        sleep 1
    done

done

echo "======================================================"
echo "Setup"
docker-compose up -d --build util

echo "======================================================"
echo "Logs"
docker-compose logs -f util
