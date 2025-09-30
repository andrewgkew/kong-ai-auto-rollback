#!/bin/bash

KONNECT_TOKEN=$1
NAMESPACE=${2:-kong}
KONNECT_REGION=${3:-eu}

if [ -z "$1" ]; then
  echo "Error: Missing mandatory field, Konnect Token."
  echo "Usage: $0 <konnect-token> <namespace> <konnect-region>"
  exit 1
fi

helm repo add kong https://charts.konghq.com
helm repo update

openssl req -new -x509 -nodes -newkey ec:<(openssl ecparam -name secp384r1) -keyout ./tls.key -out ./tls.crt -days 1095 -subj "/CN=kong_clustering"

CONTROL_PLANE_DETAILS=$( curl -X POST "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes" \
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     --json '{
       "name": "ai-auto-rollback"
     }')

CONTROL_PLANE_ID=$(echo $CONTROL_PLANE_DETAILS | jq -r .id)
CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' tls.crt);

curl --request POST \
  --url "https://${KONNECT_REGION}.api.konghq.com/v2/control-planes/${CONTROL_PLANE_ID}/dp-client-certificates" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $KONNECT_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{
    \"cert\": \"$CERT\"
  }"

CONTROL_PLANE_ENDPOINT=$(echo $CONTROL_PLANE_DETAILS | jq -r '.config.control_plane_endpoint | sub("https://";"")')
CONTROL_PLANE_TELEMETRY=$(echo $CONTROL_PLANE_DETAILS | jq -r '.config.telemetry_endpoint | sub("https://";"")')

kubectl create namespace ${NAMESPACE}
kubectl create secret tls kong-cluster-cert -n ${NAMESPACE} --cert=./tls.crt --key=./tls.key
helm install kong kong/kong -n ${NAMESPACE} --skip-crds --values ./values.yaml \
    --set env.cluster_control_plane=${CONTROL_PLANE_ENDPOINT}:443 \
    --set env.cluster_server_name=${CONTROL_PLANE_ENDPOINT} \
    --set env.cluster_telemetry_endpoint=${CONTROL_PLANE_TELEMETRY}:443 \
    --set env.cluster_telemetry_server_name=${CONTROL_PLANE_TELEMETRY}

kubectl apply -f https://developer.konghq.com/manifests/kic/echo-service.yaml -n ${NAMESPACE}