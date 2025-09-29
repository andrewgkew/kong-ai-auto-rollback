#!/bin/bash

NAMESPACE=${1:-kong}

helm uninstall kong -n ${NAMESPACE}
kubectl delete namespace ${NAMESPACE}

rm tls.key
rm tls.crt