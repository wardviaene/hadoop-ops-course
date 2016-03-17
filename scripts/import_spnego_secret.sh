#!/bin/bash
cp /vagrant/http_secret /etc/security/http_secret
chown hdfs:hadoop /etc/security/http_secret
chmod 440 /etc/security/http_secret
