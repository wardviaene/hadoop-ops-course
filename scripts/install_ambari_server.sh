#!/bin/sh
# Disable SELinux
setenforce 0

# Download Ambari Repository
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

# Install java-1.8
yum install java-1.8-openjdk

# Install ambari-server
yum install ambari-server
