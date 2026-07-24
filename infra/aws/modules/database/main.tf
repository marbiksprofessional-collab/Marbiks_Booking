resource "random_password" "master" {
  length  = 32
  special = false # avoid characters RDS/connection-string parsing can choke on
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnets"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Allow Postgres from the backend ECS service only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }
}

# NOTE: verify this engine_version is still available in your target region
# before applying - `aws rds describe-db-engine-versions --engine postgres
# --query "DBEngineVersions[].EngineVersion"` - AWS periodically retires old
# minor versions, and Terraform will fail cleanly (not silently) if the
# pinned version is gone, but better to check first.
resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az                  = var.multi_az
  backup_retention_period   = 7
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-postgres-final"

  tags = {
    Name = "${var.name_prefix}-postgres"
  }
}

# Connection details for the backend, consumed as ECS task secrets rather
# than plaintext environment variables. This is the single source of truth
# for DB_HOST/DB_PORT/DB_USERNAME/DB_PASSWORD/DB_DATABASE.
resource "aws_secretsmanager_secret" "db" {
  name        = "${var.name_prefix}/database"
  description = "Marbiks ERP backend Postgres connection details"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    DB_HOST     = aws_db_instance.this.address
    DB_PORT     = tostring(aws_db_instance.this.port)
    DB_USERNAME = var.db_username
    DB_PASSWORD = random_password.master.result
    DB_DATABASE = var.db_name
  })
}
