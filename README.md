
docker-compose file which build couchbase 3-nodes cluster 
* add nodes
* add bucket
* set creds
* create primary index
* join nodes to cluster
* rebalance
* set GSI
* Declare primary indices on nodes


Changes, please modify below files:

    start.sh
    util/setup.sh

Build

    ./start.sh

Remove

    ./del.sh
