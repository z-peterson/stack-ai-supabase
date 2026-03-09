resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.identifier}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.identifier}-params"
  family = "postgres15"

  parameter {
    name  = "rds.logical_replication"
    value = "1"
  }

  parameter {
    name  = "max_replication_slots"
    value = "10"
  }

  parameter {
    name  = "max_wal_senders"
    value = "10"
  }

  parameter {
    name  = "wal_level"
    value = "logical"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_cron"
  }

  parameter {
    name         = "cron.database_name"
    value        = "supabase"
    apply_method = "pending-reboot"
  }

  tags = {
    Name        = "${var.identifier}-params"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.identifier}-rds-sg"
  description = "Security group for Supabase RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  tags = {
    Name        = "${var.identifier}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.instance_class

  multi_az = true

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:30-sun:05:30"
  performance_insights_enabled = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"
  deletion_protection       = var.deletion_protection

  tags = {
    Name        = var.identifier
    Environment = var.environment
  }
}
