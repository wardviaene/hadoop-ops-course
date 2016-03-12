#!/bin/sh
# Disable SELinux
setenforce 0

# Download Ambari Repository
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

# Install java-1.8
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Install ambari-server
yum -y install ambari-agent

# set /etc/hosts
echo '127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4' > /etc/hosts
echo '::1 localhost localhost.localdomain localhost6 localhost6.localdomain6' >> /etc/hosts
echo '192.168.199.2 node1.example.com' >> /etc/hosts
echo '192.168.199.3 node2.example.com' >> /etc/hosts
echo '192.168.199.4 node3.example.com' >> /etc/hosts

# replace localhost in node1
cat /etc/ambari-agent/conf/ambari-agent.ini |sed 's/localhost/node1.example.com/g' > /etc/ambari-agent/conf/ambari-agent.ini.new
mv -f /etc/ambari-agent/conf/ambari-agent.ini.new /etc/ambari-agent/conf/ambari-agent.ini

# start ambari-agent
ambari-agent start

# install ntp
yum -y install ntp
systemctl enable ntpd
service ntpd start

# install deltarpm
yum install -y deltarpm
