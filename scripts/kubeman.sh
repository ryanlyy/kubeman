#! /usr/bin/bash

Usage() {
    echo " $0 show-cluster"
    echo " $0 show-all"
}
ACTION=$1

show_cluster() {
    kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'
}

show_all() {

    ##CLUSTER_NAME=$1
    ##APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")
    ##TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
    #curl -s -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
    ##APIS=$(curl -s -X GET --header "Authorization: Bearer $TOKEN" --insecure $APISERVER/apis | jq -r '[.groups | .[].name] | join(" ")')

    # do core resources first, which are at a separate api location
    ##api="core"
    ##curl -s -X GET --header "Authorization: Bearer $TOKEN" --insecure $APISERVER/api/v1 | jq -r --arg api "$api" '.resources | .[] | "\($api) \(.name): \(.verbs | join(" "))"'

    # now do non-core resources
    ##for api in $APIS; do
    ##    version=$(curl -s -X GET --header "Authorization: Bearer $TOKEN" --insecure $APISERVER/apis/$api | jq -r '.preferredVersion.version')
    ##    curl -s -X GET --header "Authorization: Bearer $TOKEN" --insecure  $SERVER/apis/$api/$version | jq -r --arg api "$api" '.resources | .[]? | "\($api) \(.name): \(.verbs | join(" "))"'
    ##done
    RES_NAME=$(kubectl api-resources --verbs=list -o name)
    for res in $RES_NAME; do
        echo "#################################################################"
        echo "show resource $res"
        kubectl get --all-namespaces $res
    done
}
if [[ $ACTION == "show-cluster" ]]; then
    show_cluster
elif [[ $ACTION == "show-all" ]]; then
    #CLUSTER_NAME=$2
    show_all #$CLUSTER_NAME
else
    Usage
fi
