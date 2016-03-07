#!/bin/bash
read -p "What is the cluster name? " CLUSTERNAME
CLUSTERNAME_FORMATTED=`echo -n $CLUSTERNAME`
curl -u admin:admin http://localhost:8080/api/v1/clusters/${CLUSTERNAME_FORMATTED}?format=blueprint > blueprint.json
echo "Wrote blueprint.json."
