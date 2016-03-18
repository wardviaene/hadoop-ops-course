#!/bin/bash
# beeline with kerberos
HADOOP_OPTS="-Djavax.security.auth.useSubjectCredsOnly=false" beeline -u 'jdbc:hive2://localhost:10000/default;principal=hive/node2.example.com@EXAMPLE.COM;auth=kerberos vagrant dummy'
