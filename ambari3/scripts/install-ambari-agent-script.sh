#!/bin/bash

set -ex

tee /etc/yum.repos.d/ambari.repo << EOF
[ambari]
name=Ambari Repository
baseurl=http://bigtop_hostname0
gpgcheck=0
enabled=1
EOF

if [ -z "$1" ]
  then
    echo "No hostname supplied"
fi

AMBARI_AGENT_HOSTNAME="$1"

hostname $1

# ambari agent
yum install -y python3 python3-distro
yum install -y java-17-openjdk-devel
yum install -y java-1.8.0-openjdk-devel
yum install -y ambari-agent

# setup agent
sed -i "s/hostname=.*/hostname=${AMBARI_AGENT_HOSTNAME}/" /etc/ambari-agent/conf/ambari-agent.ini

# we can start agent later
ambari-agent start

