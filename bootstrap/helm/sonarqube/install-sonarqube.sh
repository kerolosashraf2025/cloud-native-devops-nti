#!/usr/bin/env bash
set -e

echo "=========================================="
echo "Installing SonarQube..."
echo "=========================================="

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

kubectl create namespace sonarqube --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --set service.type=LoadBalancer

echo "=========================================="
echo "Waiting for SonarQube to be ready..."
echo "=========================================="
kubectl rollout status deployment/sonarqube-sonarqube -n sonarqube --timeout=900s || true

echo "=========================================="
echo "SonarQube Service:"
echo "=========================================="
kubectl get svc -n sonarqube
