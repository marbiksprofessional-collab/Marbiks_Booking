variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group (the ECS service's) allowed to reach Postgres on port 5432."
  type        = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage_gb" {
  type = number
}

variable "engine_version" {
  type = string
}

variable "multi_az" {
  type = bool
}
