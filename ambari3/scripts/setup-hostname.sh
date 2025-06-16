#!/bin/bash

# Run this file when containers are restarted and have new IP addresses

set -ex 

# setup hostnames

INSTANCES="bigtop_hostname0 bigtop_hostname1 bigtop_hostname2 bigtop_hostname3"

rm -f hosts
echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
' > hosts
for i in $INSTANCES ; do
	docker compose exec -it $i yum install net-tools -y
	docker compose cp getip.sh $i:/root/getip.sh
	IP=$(docker compose exec -it $i /bin/bash /root/getip.sh)
	HOSTNAME=$(docker compose exec -it $i hostname)
	HOSTNAME_SHORT=$(docker compose exec -it $i hostname -f)
	echo "$IP $HOSTNAME_SHORT $HOSTNAME" >> hosts
done

if [ $(basename $PWD) == "scripts" ] ; then
	cat hosts > ../conf/hosts
else
	cat hosts > conf/hosts
fi
rm hosts
