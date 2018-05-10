#!/bin/bash

CLUSTER_NAME=dopsch
CLUSTER_ZONE=europe-west1-b
# gigabytes
DISK_SIZE=20
MACHINE_TYPE=n1-standard-1
NUM_NODES=1
NAMESPACE=dopsch
DOPSCH_HELM_RELEASE_NAME=dopsch
NGINX_HELM_INGRESS_NAME=entrance
# Let's Encrypt
LEGO_HELM_RELEASE_NAME=toy
LEGO_EMAIL=abcd@osadmin.com
LEGO_URL=https://acme-v01.api.letsencrypt.org/directory
DNS_RECORD_NAME=dopsch
DNS_TOP_DOMAIN=trguj.com

