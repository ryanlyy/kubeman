#!/usr/bin/bash

NAME_SPACE=$1
for api_resource in $(kubectl api-resources | grep true | awk '{ print $1 }'); do 
	echo "################################################"
	echo "Kubernetes Resource: $api_resource ..."
	kubectl get -n $NAME_SPACE $api_resource 2>/dev/null
done
