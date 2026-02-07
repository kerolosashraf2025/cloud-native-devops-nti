#!/bin/bash
set -e

echo "Installing External Secrets Operator..."

if [ -z "$EXTERNAL_SECRETS_ROLE_ARN" ]; then
  echo "ERROR: EXTERNAL_SECRETS_ROLE_ARN environment variable is not set!"
  exit 1
fi

helm repo add external-secrets https://charts.external-secrets.io
helm repo update

kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --set installCRDs=true \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-secrets-sa \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$EXTERNAL_SECRETS_ROLE_ARN"

echo "External Secrets Operator installed successfully ✅"
kubectl get pods -n external-secrets
