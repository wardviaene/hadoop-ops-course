#!/bin/bash

set -ex

# ambari agent
yum install -y python3-distro
yum install -y java-17-openjdk-devel
yum install -y java-1.8.0-openjdk-devel
yum install -y ambari-agent

# ambari server
yum install -y python3-psycopg2
yum install -y ambari-server


# MySQL
yum -y install https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm

yum -y install mysql-server

rm -rf /var/lib/mysql/*
mysqld --initialize
chown -R mysql:mysql /var/lib/mysql

MYSQL_ROOT_PASS=$(cat /var/log/mysql/mysqld.log |grep -i 'password is generated' |rev |cut -d ':' -f1 |rev |sed 's/\ //g')

systemctl start mysqld.service
systemctl enable mysqld.service

echo "
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'ambarirootpass';
-- Create Ambari user and grant privileges
CREATE USER 'ambari'@'localhost' IDENTIFIED BY 'ambari';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'localhost';
CREATE USER 'ambari'@'%' IDENTIFIED BY 'ambari';
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';

-- Create required databases
CREATE DATABASE ambari CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE hive;
CREATE DATABASE ranger;
CREATE DATABASE rangerkms;

-- Create service users
CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%';

CREATE USER 'ranger'@'%' IDENTIFIED BY 'ranger';
GRANT ALL PRIVILEGES ON *.* TO 'ranger'@'%' WITH GRANT OPTION;

CREATE USER 'rangerkms'@'%' IDENTIFIED BY 'rangerkms';
GRANT ALL PRIVILEGES ON rangerkms.* TO 'rangerkms'@'%';

FLUSH PRIVILEGES;" > /root/ambari-server-setup.sql

mysql --connect-expired-password -u root -p''${MYSQL_ROOT_PASS}'' < /root/ambari-server-setup.sql

mysql --connect-expired-password -uambari -pambari ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql

# setup Ambari MySQL

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar \
  -O /usr/share/java/mysql-connector-java.jar

ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar

echo "server.jdbc.url=jdbc:mysql://localhost:3306/ambari?useSSL=true&verifyServerCertificate=false&enabledTLSProtocols=TLSv1.2" >> /etc/ambari-server/conf/ambari.properties

ambari-server setup -s \
  -j /usr/lib/jvm/java-1.8.0-openjdk \
  --ambari-java-home /usr/lib/jvm/java-17-openjdk \
  --database=mysql \
  --databasehost=localhost \
  --databaseport=3306 \
  --databasename=ambari \
  --databaseusername=ambari \
  --databasepassword=ambari


ambari-server start

