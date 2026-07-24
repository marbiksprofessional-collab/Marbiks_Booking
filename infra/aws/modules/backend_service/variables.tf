variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN with DB_HOST/DB_PORT/DB_USERNAME/DB_PASSWORD/DB_DATABASE keys."
  type        = string
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "health_check_path" {
  type = string
}
