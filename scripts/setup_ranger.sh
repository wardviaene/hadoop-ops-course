#!/bin/bash
yum -y install mysql-connector-java
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
ssh vagrant@node2.example.com 'mysql -u root -e "source /vagrant/scripts/ranger.sql"'

