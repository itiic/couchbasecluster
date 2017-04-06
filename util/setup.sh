#!/bin/bash

echo "======================================================================="

clusterName=clustename
username=admin
password=pass1234
bucket=buck


# master
echo "MASTER"
echo "======================================================================="

step0=$(curl -s -w "%{http_code}" -X POST http://couchbase1.couchcluster:8091/node/controller/rename -d hostname=couchbase1.couchcluster)
echo step0 status code: ${step0}

step1=$(curl -s -w "%{http_code}" -X POST http://couchbase1.couchcluster:8091/pools/default -d clusterName="${clusterName}" -d memoryQuota=300 -d indexMemoryQuota=300)
echo step1 status code: ${step1}

step2=$(curl -s -w "%{http_code}" -X POST http://couchbase1.couchcluster:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex')
echo step2 status code: ${step2}

step3=$(curl -s -w "%{http_code}" -X POST http://couchbase1.couchcluster:8091/settings/web -d port=8091 -d username="${username}" -d password="${password}")
echo step3 status code: ${step3}

step4=$(curl -s -w "%{http_code}" -X POST -u ${username}:${password} http://couchbase1.couchcluster:8091/pools/default/buckets -d name="${bucket}" -d ramQuotaMB=100 -d authType=none -d proxyPort=11216)
echo step4 status code: ${step4}

step5=$(curl -s -w "%{http_code}" -X POST -u ${username}:${password} http://couchbase1.couchcluster:8093/query/service -d 'statement=CREATE PRIMARY INDEX ON `'${bucket}'`')
echo step5 status code: ${step5}

sleep 2

# node2
echo "======================================================================="
echo "NODE2"
curl -s -w "%{http_code}" -X POST http://couchbase2.couchcluster:8091/pools/default -d memoryQuota=300 -d indexMemoryQuota=300
curl -s -w "%{http_code}" -X POST http://couchbase2.couchcluster:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex'
curl -s -w "%{http_code}" -X POST http://couchbase2.couchcluster:8091/settings/web -d port=8091 -d username="${username}" -d password="${password}"

sleep 5

curl -s -w "%{http_code}" -X POST -u ${username}:${password} http://couchbase1.couchcluster:8091/controller/addNode -d 'user='${username}'' -d 'password='${password}'' -d 'services=kv%2Cn1ql%2Cindex' -d 'hostname=couchbase2.couchcluster'

sleep 2

# node3
echo "======================================================================="
echo "NODE3"
curl -s -w "%{http_code}" -X POST http://couchbase3.couchcluster:8091/pools/default -d memoryQuota=300 -d indexMemoryQuota=300
curl -s -w "%{http_code}" -X POST http://couchbase3.couchcluster:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex'
curl -s -w "%{http_code}" -X POST http://couchbase3.couchcluster:8091/settings/web -d port=8091 -d username="${username}" -d password="${password}"

sleep 5

curl -s -w "%{http_code}" -X POST -u ${username}:${password} http://couchbase1.couchcluster:8091/controller/addNode -d 'user='${username}'' -d 'password='${password}'' -d 'services=kv%2Cn1ql%2Cindex' -d 'hostname=couchbase3.couchcluster'

sleep 5

# Rebalance
echo "======================================================================="
echo "Rebalance"
curl -s -w "%{http_code}" -X POST -u ${username}:${password} http://couchbase1.couchcluster:8091/controller/rebalance -d 'knownNodes=ns_1@couchbase1.couchcluster,ns_1@couchbase2.couchcluster,ns_1@couchbase3.couchcluster'

sleep 2

# Set the Global Secondary Index Settings
echo "======================================================================="
echo "Set the Global Secondary Index Settings"
curl -X POST -u ${username}:${password} http://couchbase1.couchcluster:8091/settings/indexes -d 'storageMode=memory_optimized'
curl -X POST -u ${username}:${password} http://couchbase2.couchcluster:8091/settings/indexes -d 'storageMode=memory_optimized'
curl -X POST -u ${username}:${password} http://couchbase3.couchcluster:8091/settings/indexes -d 'storageMode=memory_optimized'

sleep 2

# Declare primary indices on nodes
echo "======================================================================="
echo "Declare primary indices on nodes"

curl -u ${username}:${password} http://couchbase1.couchcluster:8093/query/service -d 'statement=CREATE PRIMARY INDEX idx_test_1 ON `'${bucket}'` USING GSI WITH {"nodes":["couchbase1.couchcluster:8091"]};'
curl -u ${username}:${password} http://couchbase2.couchcluster:8093/query/service -d 'statement=CREATE PRIMARY INDEX idx_test_2 ON `'${bucket}'` USING GSI WITH {"nodes":["couchbase2.couchcluster:8091"]};'
curl -u ${username}:${password} http://couchbase3.couchcluster:8093/query/service -d 'statement=CREATE PRIMARY INDEX idx_test_3 ON `'${bucket}'` USING GSI WITH {"nodes":["couchbase3.couchcluster:8091"]};'


echo "======================================================================="
