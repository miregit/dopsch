#!/bin/bash
set -e

if [ -z $DIGITAL_OCEAN_API_TOKEN ]; then
cat << EOD
To automatically update DNS at DigitalOcean this script requires DIGITAL_OCEAN_API_TOKEN environment variable.
Since you didn't specify it, you will need to manually update your DNS later.

EOD
        while true; do
            read -p "Do you wish to continue? " yn
            case $yn in
                [Yy]* ) echo "Going on"; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done

fi

. ./common.sh

gcloud container clusters create $CLUSTER_NAME \
  --disk-size $DISK_SIZE \
  --zone $CLUSTER_ZONE \
  --enable-cloud-logging \
  --enable-cloud-monitoring \
  --machine-type $MACHINE_TYPE \
  --num-nodes $NUM_NODES

# create namespace and set it as default

echo "creating and setting namespace $NAMESPACE"
kubectl create namespace $NAMESPACE
kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE

# install helm in the cluster

echo "installing helm"
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller
# --wait, block until tiller is ready to service requests
helm init --service-account tiller --wait

helm repo update

# give some time to tiller
sleep 15

# install nginx ingress

echo "installing nginx ingress via helm"
helm upgrade --install --wait --timeout 120 --namespace kube-system --set "rbac.create=true" $NGINX_HELM_INGRESS_NAME stable/nginx-ingress

# wait for load balancer to get external IP

echo "waiting to get load balancer external ip"
external_ip=""
while [ -z $external_ip ]; do
    sleep 10
    external_ip=$(kubectl -n kube-system get svc $NGINX_HELM_INGRESS_NAME-nginx-ingress-controller --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    echo -n "."
done

echo
echo "got $external_ip"

# install Let's Encrypt

echo "installing Let's Encrypt via helm"
helm upgrade --install --wait --timeout 420 --namespace kube-system --set "config.LEGO_EMAIL=$LEGO_EMAIL,config.LEGO_URL=$LEGO_URL,rbac.create=true" $LEGO_HELM_RELEASE_NAME stable/kube-lego

if [ ! -z $DIGITAL_OCEAN_API_TOKEN ]; then

        # first get ID of our subdomain
        SUBDOMAIN_ID=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITAL_OCEAN_API_TOKEN" "https://api.digitalocean.com/v2/domains/$DNS_TOP_DOMAIN/records"|jq ".domain_records |.[]|select(.name==\"$DNS_RECORD_NAME\").id")

        curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITAL_OCEAN_API_TOKEN" -d "{\"data\":\"$external_ip\"}" "https://api.digitalocean.com/v2/domains/$DNS_TOP_DOMAIN/records/$SUBDOMAIN_ID"
	echo

else
        echo "Skipping A record creation for DNS"
fi

# install dopsch helm chart

echo "installing dopsch helm chart"
helm upgrade --install --namespace $NAMESPACE --wait --timeout 120  $DOPSCH_HELM_RELEASE_NAME ./chart

