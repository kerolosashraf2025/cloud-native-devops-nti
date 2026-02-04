#!/usr/bin/env bash
set -e

NAMESPACE="datadog"
RELEASE_NAME="datadog"

echo "👉 Creating datadog namespace (if not exists)"
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

echo "👉 Creating Datadog secret"
kubectl delete secret datadog-secret -n $NAMESPACE --ignore-not-found
kubectl create secret generic datadog-secret \
  --from-literal=api-key="${DATADOG_API_KEY}" \
  -n $NAMESPACE

echo "👉 Adding Datadog Helm repo"
helm repo add datadog https://helm.datadoghq.com
helm repo update

echo "👉 Installing / Upgrading Datadog Agent"
helm upgrade --install $RELEASE_NAME datadog/datadog \
  --namespace $NAMESPACE \
  -f bootstrap/helm/datadog/datadog-values.yaml \
  --set datadog.clusterName="${CLUSTER_NAME}"

echo "✅ Datadog installation completed"
