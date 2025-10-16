
output "cluster_name" { value = module.eks.cluster_id }
output "eks_cluster_endpoint" { value = module.eks.cluster_endpoint }
output "ecr_book_api" { value = aws_ecr_repository.book_api.repository_url }
output "ecr_user_service" { value = aws_ecr_repository.user_service.repository_url }
output "ecr_frontend" { value = aws_ecr_repository.frontend.repository_url }
output "rds_endpoint" { value = aws_db_instance.postgres.address }
