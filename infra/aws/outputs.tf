output "alb_dns_name" {
  description = "Public DNS name of the load balancer in front of the backend. Point a CNAME here, or hit it directly to reach the API."
  value       = module.backend_service.alb_dns_name
}

output "ecr_repository_url" {
  description = "Push backend Docker images here (the CI/CD workflow does this automatically)."
  value       = module.backend_service.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.backend_service.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.backend_service.ecs_service_name
}

output "db_endpoint" {
  description = "RDS endpoint. Only reachable from within the VPC (private subnets) - not publicly accessible by design."
  value       = module.database.db_endpoint
}

output "github_actions_deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN value used by .github/workflows/deploy-backend.yml (repo variable or secret)."
  value       = module.github_oidc.deploy_role_arn
}
