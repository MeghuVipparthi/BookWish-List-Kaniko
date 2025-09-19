
#!/usr/bin/env bash
set -euo pipefail

echo "This script automates: terraform apply, update kubeconfig, create regcred, run kaniko jobs, deploy manifests."
echo "Edit variables at the top before running."

AWS_REGION="eu-central-1"
PROJECT="bookwish-ms"
TF_DIR="terraform"

# 1. Terraform apply
pushd $TF_DIR
terraform init
terraform apply -auto-approve
# Capture outputs (requires terraform >= 0.12)
ECR_BOOK_API=$(terraform output -raw ecr_book_api || true)
ECR_USER=$(terraform output -raw ecr_user_service || true)
ECR_FRONT=$(terraform output -raw ecr_frontend || true)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint || true)
CLUSTER_NAME=$(terraform output -raw cluster_name || true)
popd

echo "ECR repos: $ECR_BOOK_API, $ECR_USER, $ECR_FRONT"
echo "RDS endpoint: $RDS_ENDPOINT"
echo "Cluster: $CLUSTER_NAME"

# 2. Update kubeconfig
aws eks --region $AWS_REGION update-kubeconfig --name "$CLUSTER_NAME"

# 3. Create namespace
kubectl apply -f k8s/manifests/namespace.yaml

# 4. Create regcred (dev) - ensure AWS CLI is configured
aws ecr get-login-password --region $AWS_REGION | kubectl create secret docker-registry regcred \
  --docker-server=$(echo $ECR_BOOK_API | sed 's|/.*||') \
  --docker-username=AWS --docker-password-stdin -n bookwish || true

# 5. Apply secret (edit secret.yaml with RDS values before applying)
kubectl apply -f k8s/manifests/secret.yaml

# 6. Run Kaniko jobs
kubectl apply -f kaniko/kaniko-build-bookapi.yaml
kubectl apply -f kaniko/kaniki-build-user-service.yaml || kubectl apply -f kaniko/kaniko-build-user-service.yaml
kubectl apply -f kaniko/kaniko-build-frontend.yaml

echo "Tail logs for Kaniko jobs to verify image builds."

# 7. Deploy microservices (ensure manifests have correct ECR image URLs)
kubectl apply -f k8s/manifests/book-api-deployment.yaml
kubectl apply -f k8s/manifests/book-api-service.yaml
kubectl apply -f k8s/manifests/user-service-deployment.yaml
kubectl apply -f k8s/manifests/user-service-service.yaml
kubectl apply -f k8s/manifests/frontend-deployment.yaml
kubectl apply -f k8s/manifests/frontend-service.yaml
kubectl apply -f k8s/manifests/book-api-hpa.yaml

echo "Deployment commands executed. Check 'kubectl get all -n bookwish'."
