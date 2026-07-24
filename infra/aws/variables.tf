variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1" # Mumbai - closest region to India for Marbiks' branches
}

variable "project_name" {
  description = "Short name used to prefix/tag every resource this stack creates."
  type        = string
  default     = "marbiks-erp"
}

variable "environment" {
  description = "Deployment environment name (e.g. production, staging)."
  type        = string
  default     = "production"
}

variable "github_org" {
  description = "GitHub org/user that owns this repo, for scoping the CI/CD OIDC role (e.g. 'marbiksprofessional-collab')."
  type        = string
}

variable "github_repo" {
  description = "Repo name only, no org prefix (e.g. 'marbiks_booking'), for scoping the CI/CD OIDC role."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across. Must have at least 2 for RDS Multi-AZ and ALB."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB, NAT gateway), one per AZ."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (ECS tasks, RDS), one per AZ."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

# --- Database ---

variable "db_name" {
  description = "Postgres database name."
  type        = string
  default     = "marbiks_erp"
}

variable "db_username" {
  description = "Postgres master username."
  type        = string
  default     = "marbiks"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_allocated_storage_gb" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 50
}

variable "db_engine_version" {
  description = "Postgres engine version (should match what the backend was tested against - see backend/README, Postgres 16)."
  type        = string
  default     = "16.4"
}

variable "db_multi_az" {
  description = "Whether to run RDS in Multi-AZ (recommended for production, doubles DB cost)."
  type        = bool
  default     = true
}

# --- Backend service (ECS Fargate) ---

variable "container_image" {
  description = <<-EOT
    Full ECR image URI to deploy, e.g.
    123456789012.dkr.ecr.ap-south-1.amazonaws.com/marbiks-erp-backend:latest.
    No default on purpose - the CI/CD workflow (.github/workflows/deploy-backend.yml)
    builds and pushes this image, then passes its URI here. For a first manual
    apply, build+push once yourself and pass -var="container_image=...".
  EOT
  type        = string
}

variable "container_port" {
  description = "Port the NestJS backend listens on inside the container (matches PORT in backend/.env.example)."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of backend tasks to run."
  type        = number
  default     = 2
}

variable "task_cpu" {
  description = "Fargate task vCPU units (256 = 0.25 vCPU, 512 = 0.5 vCPU, 1024 = 1 vCPU, ...)."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory in MB. Must be a valid pairing with task_cpu - see AWS Fargate task size table."
  type        = number
  default     = 1024
}

variable "jwt_secret" {
  description = "JWT signing secret for the backend (matches JWT_SECRET in backend/.env.example). No default - supply a long random value; never commit a real value to source control."
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS on the ALB. Leave blank to serve HTTP only on port 80 (fine for initial setup, not recommended for real production traffic)."
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "ALB target group health check path - matches the backend's GET /api/v1/health endpoint."
  type        = string
  default     = "/api/v1/health"
}
