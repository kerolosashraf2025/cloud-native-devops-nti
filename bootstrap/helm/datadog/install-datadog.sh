#!/bin/bash
set -e

NAMESPACE=datadog

echo "Creating datadog namespace (if not exists)"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Creating Datadog secret"
kubectl create secret generic datadog-secret \
  --from-literal=api-key=$DATADOG_API_KEY \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Adding Datadog Helm repo"
helm repo add datadog https://helm.datadoghq.com
helm repo update

echo "Installing Datadog Agent"
helm upgrade --install datadog datadog/datadog \
  -n $NAMESPACE \
  -f bootstrap/datadog/datadog-values.yaml

echo "Datadog installation completed"
