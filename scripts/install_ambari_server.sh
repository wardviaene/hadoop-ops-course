#!/bin/sh
# Disable SELinux
setenforce 0

# Download Ambari Repository
#wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
echo '[MOSGA]
name=MOSGA Open Source Repository
baseurl=https://makeopensourcegreatagain.com/rpms/
enabled=1
gpgcheck=0' > /etc/yum.repos.d/ambari.repo

# Install java-1.8
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# Install ambari-server
yum -y install ambari-server

# bootstrap ambari-server
ambari-server setup -s --java-home=/usr/lib/jvm/jre/

# disable ssl checks
sed -i 's/verify=platform_default/verify=disable/' /etc/python/cert-verification.cfg || echo "could not disable ssl checks"

# start ambari-server
ambari-server start

# install management pack
ambari-server install-mpack --mpack=https://github.com/wardviaene/dfhz_ddp_mpack/raw/master/ddp-ambari-mpack-0.0.0.4-5.tar.gz --verbose

# restart ambari-server
ambari-server restart

sh /vagrant/scripts/install_ambari_agent.sh
