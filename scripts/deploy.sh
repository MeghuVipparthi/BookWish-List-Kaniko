#!/usr/bin/env bash
set -euo pipefail

# This script runs terraform for infra and deploys the application using Helm.
# It assumes AWS CLI and kubectl are configured and you have permissions.
# Edit variables below before running.

AWS_REGION="eu-central-1"
PROJECT="bookwish-ms"
TF_DIR="infra/terraform"
HELM_RELEASE="bookwish"
HELM_CHART_DIR="deploy/helm/bookwish-chart"
NAMESPACE="bookwish"

echo "1) Apply Terraform (creates infra, ECR, cluster context updates)"
pushd "$TF_DIR"
terraform init
terraform apply -auto-approve
# Capture outputs if needed; user can run 'terraform output' manually
popd

echo "2) Create namespace (if not exists)"
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo "3) Apply Kaniko jobs to build images (these push to ECR). Edit kaniko manifests if needed."
kubectl apply -f deploy/kaniko/namespace.yaml
kubectl apply -f deploy/kaniko/kaniko-build-bookapi.yaml
kubectl apply -f deploy/kaniko/kaniko-build-user-service.yaml
kubectl apply -f deploy/kaniko/kaniko-build-frontend.yaml

echo "Note: Wait for Kaniko jobs to complete and images to be available in ECR before proceeding."
echo "You can tail logs: kubectl -n kaniko logs job/<job-name> --follow"

echo "4) Helm upgrade --install the application"
helm upgrade --install "$HELM_RELEASE" "$HELM_CHART_DIR" --namespace "$NAMESPACE" --create-namespace

echo "Done. To view resources: kubectl get all -n $NAMESPACE"
