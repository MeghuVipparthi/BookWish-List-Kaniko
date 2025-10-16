# Bookwish — Refactor with Terraform + Helm + Kaniko

This refactor organizes infrastructure and deployment:

- `infra/terraform/` : Terraform code (unchanged)
- `deploy/helm/bookwish-chart/` : Helm chart for Kubernetes manifests (converted from k8s/manifests)
- `deploy/kaniko/` : Kaniko job manifests (moved)
- `scripts/deploy.sh` : Updated script using `helm upgrade --install` instead of multiple `kubectl apply`
- `docs/` : documentation

Git workflow recommended:
1. Create a feature branch and push:
   ```
   git checkout -b feature/bookwish-list-kaniko
   git add .
   git commit -m "refactor: move manifests into Helm chart, update deploy script"
   git push origin feature/bookwish-list-kaniko
   ```
2. Open a PR, review, iterate on feedback. Make changes on the same branch.
3. Once approved, merge into `main` via PR.

Helm notes:
- Replace image placeholders in `deploy/helm/bookwish-chart/values.yaml` with your ECR image URIs or use a CI pipeline to set them.
- Terraform still creates infra; keep responsibilities separated.

