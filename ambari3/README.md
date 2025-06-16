# Ambari3 installation instructions

Clone this repository first and cd into the ambari3 directory.

## Start the containers
```
docker compose up -d
```

The next commands will run from the `scripts/` directory in `ambari3/`

## Setup the Ambari repository
This can take a while (repository is +- 7GB)
```
./setup-ambari-repo.sh  # cd scripts/ first
```

## Setup hostnames
We need to set the hostnames in the hostname file correctly:
```
./setup-hostname.sh
```
Also when you restart the containers and they have new IP addresses, update the hostfile by executing this script.

## Run setup for every node
```
./setup.sh
```

## Install ambari-server on first node
```
./install-ambari-server.sh
```
## Install ambari-server on all nodes
```
./install-ambari-agent.sh
```

## Setup Cluster
You can now login to http://localhost:8080 (login & password are admin) to setup the cluster

### Configuration
* When asked for the baseURL, supply http://bigtop-hostname0.demo.local. Your OS is Redhat 8 based.
* When asked for installation nodes, list all nodes: bigtop-hostname0.demo.local bigtop-hostname1.demo.local bigtop-hostname2.demo.local bigtop-hostname3.demo.local
