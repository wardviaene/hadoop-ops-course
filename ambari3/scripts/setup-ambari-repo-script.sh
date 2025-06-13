#!/bin/bash

set -ex

dnf install createrepo -y

cd /var/repo/ambari
wget -r -N -np -nH --cut-dirs=4 --reject 'index.html*' https://www.apache-ambari.com/dist/ambari/3.0.0/rocky8/
wget -r -N -np -nH --cut-dirs=4 --reject 'index.html*' https://www.apache-ambari.com/dist/bigtop/3.3.0/rocky8/

createrepo .

dnf clean all
dnf makecache

dnf install nginx -y

sudo tee /etc/nginx/conf.d/ambari-repo.conf << EOF
server {
    listen 80;
    server_name bigtop_hostname0 bigtop-hostname0.demo.local;
    root /var/repo/ambari;
    autoindex on;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

systemctl start nginx
systemctl enable nginx

tee /etc/yum.repos.d/ambari.repo << EOF
[ambari]
name=Ambari Repository
baseurl=http://bigtop_hostname0
gpgcheck=0
enabled=1
EOF
