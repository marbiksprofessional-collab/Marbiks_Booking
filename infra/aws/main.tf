locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "backend_service" {
  source = "./modules/backend_service"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  container_image = var.container_image
  container_port  = var.container_port
  desired_count   = var.desired_count
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory

  db_secret_arn     = module.database.secret_arn
  jwt_secret        = var.jwt_secret
  certificate_arn   = var.certificate_arn
  health_check_path = var.health_check_path
}

module "database" {
  source = "./modules/database"

  name_prefix               = local.name_prefix
  vpc_id                    = module.network.vpc_id
  private_subnet_ids        = module.network.private_subnet_ids
  allowed_security_group_id = module.backend_service.ecs_task_security_group_id

  db_name              = var.db_name
  db_username          = var.db_username
  instance_class       = var.db_instance_class
  allocated_storage_gb = var.db_allocated_storage_gb
  engine_version       = var.db_engine_version
  multi_az             = var.db_multi_az
}

module "github_oidc" {
  source = "./modules/github_oidc"

  name_prefix = local.name_prefix
  github_org  = var.github_org
  github_repo = var.github_repo

  ecr_repository_arn      = module.backend_service.ecr_repository_arn
  ecs_cluster_arn         = module.backend_service.ecs_cluster_arn
  ecs_service_arn         = module.backend_service.ecs_service_arn
  task_execution_role_arn = module.backend_service.task_execution_role_arn
  task_role_arn           = module.backend_service.task_role_arn
}
