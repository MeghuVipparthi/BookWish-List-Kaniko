
BookWish EKS Microservices Package
==================================

This package contains Terraform, Kaniko job manifests, Kubernetes manifests, and helper scripts to:
- Provision a separate EKS cluster (VPC, EKS, nodegroups) using Terraform
- Create ECR repositories for microservices
- Optionally create an RDS Postgres instance
- Build container images inside the cluster using Kaniko and push to ECR
- Deploy microservices (book-api, user-service, frontend) to the new cluster

---

Before you start
- Install: awscli, terraform, kubectl, eksctl (optional), docker (for local testing)
- Configure AWS CLI with credentials that have permissions to create VPC, EKS, ECR, RDS, IAM, etc.
- Edit values in terraform/variables.tf if needed (region, passwords, cluster name)

Quick start
1. cd terraform && terraform init && terraform apply -auto-approve
2. aws eks --region <region> update-kubeconfig --name $(terraform output -raw cluster_name)
3. Edit k8s/manifests/secret.yaml and replace <RDS_ENDPOINT_OR_SERVICE> and <DB_PASSWORD> placeholders
4. kubectl apply -f k8s/manifests/namespace.yaml
5. Create ECR regcred secret (or setup IRSA for Kaniko)
6. kubectl apply -f kaniko/kaniko-build-bookapi.yaml ... (for each service)
7. Wait for images in ECR and update image placeholders in k8s manifests or use terraform outputs to template them
8. kubectl apply -f k8s/manifests/

Security notes
- For production use IRSA (IAM Roles for Service Accounts) instead of storing AWS credentials in k8s secrets.
- Use AWS Secrets Manager or kubernetes-external-secrets for DB credentials.
