#!/bin/bash

set -e

dnf install createrepo

cd /var/repo/ambari
wget -r -np -nH --cut-dirs=4 --reject 'index.html*' https://www.apache-ambari.com/dist/ambari/3.0.0/rocky8/
wget -r -np -nH --cut-dirs=4 --reject 'index.html*' https://www.apache-ambari.com/dist/bigtop/3.3.0/rocky8/

createrepo .

tee /etc/yum.repos.d/ambari.repo << EOF
[ambari]
name=Ambari Repository
baseurl=http://bigtop_hostname0/ambari-repo
gpgcheck=0
enabled=1
EOF


dnf clean all
dnf makecache
