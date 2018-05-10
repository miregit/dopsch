#!/bin/bash

. ./common.sh

echo "deleting secret "
kubectl delete secret dopsch-tls

echo "deleting helm charts"

helm delete --purge $DOPSCH_HELM_RELEASE_NAME
helm delete --purge $LEGO_HELM_RELEASE_NAME
helm delete --purge $NGINX_HELM_INGRESS_NAME

# delete cluster
echo "deleting cluster $CLUSTER_NAME"

gcloud container clusters delete "$CLUSTER_NAME"

