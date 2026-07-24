output "deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN GitHub Actions secret/variable used by .github/workflows/deploy-backend.yml."
  value       = aws_iam_role.deploy.arn
}
