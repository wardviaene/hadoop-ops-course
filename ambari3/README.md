# Ambari3 installation instructions

## Start the containers
```
docker compose up -d
```

## Setup the Ambari repository
This can take a while (repository is +- 7GB)
```
scripts/setup-ambari-repo.sh
```

## Run setup for every node
```
scripts/setup.sh
```

## Install ambari-server on first node
```
scripts/install-ambari-server.sh
```
## Install ambari-server on all nodes
```
scripts/install-ambari-agent.sh
```

## Setup Cluster
You can now login to http://localhost:8080 (login & password are admin) to setup the cluster

### Configuration
* When asked for the baseURL, supply http://bigtop-hostname0.demo.local. Your OS is Redhat 8 based.
* When asked for installation nodes, list all nodes: bigtop-hostname0.demo.local bigtop-hostname1.demo.local bigtop-hostname2.demo.local bigtop-hostname3.demo.local
