#!/bin/bash
set -e

echo "Installing External Secrets Operator..."

helm repo add external-secrets https://charts.external-secrets.io
helm repo update

kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --set installCRDs=true

echo "External Secrets Operator installed successfully ✅"
kubectl get pods -n external-secrets

