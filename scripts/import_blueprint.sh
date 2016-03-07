#!/bin/bash
read -p "Where is the blueprint.json located? " JSON1 
read -p "Where is the template.json located? " JSON2 
read -p "Please enter a cluster name: " CLUSTERNAME
JSON1_FORMATTED=`echo -n $JSON1`
JSON2_FORMATTED=`echo -n $JSON2`
CLUSTERNAME_FORMATTED=`echo -n $CLUSTERNAME`

curl -u admin:admin -X POST -d @${JSON1_FORMATTED} http://localhost:8080/api/v1/blueprints/
curl -u admin:admin -X POST -d @${JSON2_FORMATTED} http://localhost:8080/api/v1/clusters/${CLUSTERNAME_FORMATTED}

echo "Imported blueprint and created cluster"
