#!/bin/sh

# Start Solr
docker run --name my_solr -d --rm -p 8983:8983 -t solr
docker exec -it --user=solr my_solr bin/solr create_core -c xyzzy

# Start HDFS
docker run -it --rm -p 9000:9000 -p 50070:50070 -p 50010:50010 -p 50075:50075 lockss/lockss-hadoop

