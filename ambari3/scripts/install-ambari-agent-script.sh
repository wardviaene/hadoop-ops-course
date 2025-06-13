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
yum install -y chrony

# setup agent
sed -i "s/hostname=.*/hostname=bigtop-hostname0.demo.local/" /etc/ambari-agent/conf/ambari-agent.ini

# we can start agent later
AGENT_RUNNING=$(ambari-agent status |grep -c running)
if [ "$AGENT_RUNNING" != "1" ] ; then
	ambari-agent start
else
	ambari-agent restart
fi

# cleanup packages that don't need to be installed
yum remove -y rubygem-multi_json rubygem-semantic_puppet cpp-hocon rubygem-hocon rubygem-puppet-resource_api hiera leatherman ruby-facter rubygem-concurrent-ruby rubygem-deep_merge puppet rubygem-httpclient ruby-augeas facter yaml-cpp

# setup chrony 
systemctl enable chronyd
systemctl start chronyd
