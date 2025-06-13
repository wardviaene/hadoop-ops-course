#!/bin/bash

docker compose cp setup-ambari-repo-script.sh bigtop_hostname0:/root/setup-ambari-repo-script.sh
docker compose exec -it bigtop_hostname0 /bin/bash /root/setup-ambari-repo-script.sh
