variable "name_prefix" {
  type = string
}

variable "github_org" {
  description = "GitHub organization/user that owns the repo, e.g. 'marbiksprofessional-collab'."
  type        = string
}

variable "github_repo" {
  description = "Repo name only (no org prefix), e.g. 'marbiks_booking'."
  type        = string
}

variable "ecr_repository_arn" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "ecs_service_arn" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}
