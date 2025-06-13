#!/bin/bash

set -ex

docker compose cp install-ambari-server-script.sh bigtop_hostname0:/root/install-ambari-server-script.sh
docker compose exec -it bigtop_hostname0 /bin/bash /root/install-ambari-server

