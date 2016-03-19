#!/bin/bash
yum install krb5-server krb5-devel krb5-workstation krb5-libs rng-tools -y

service rngd start

echo '[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 default_realm = EXAMPLE.COM
 default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EXAMPLE.COM = {
  kdc = node2.example.com
  admin_server = node2.example.com
 }

[domain_realm]
# .example.com = EXAMPLE.COM
# example.com = EXAMPLE.COM
'> /etc/krb5.conf

kdb5_util create -P admin -s

echo '*/admin@EXAMPLE.COM  *' > /var/kerberos/krb5kdc/kadm5.acl
kadmin.local -q "addprinc -pw admin admin/admin"

# add user keyadmin for Ranger KMS
kadmin.local -q 'addprinc -pw keyadmin keyadmin'

# add user nn for Ranger KMS
adduser nn
kadmin.local -q 'addprinc -randkey nn'

service krb5kdc start
service kadmin start
