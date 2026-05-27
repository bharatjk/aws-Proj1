# ---------------------------------------------------------------------------
# RDS Subnet Group — spans both private subnets (required even for single-AZ)
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  count      = var.enable_rds ? 1 : 0
  name       = "${var.tag_name}-db-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# RDS Security Group — allow MySQL only from EC2 instances
# ---------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.tag_name}-rds-sg"
  description = "Allow MySQL from EC2 instances only"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description     = "MySQL from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.phase3.outputs.ec2_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# RDS MySQL Instance
# ---------------------------------------------------------------------------
# COST CONTROL:
#   enable_rds    = false  → no RDS created (default)
#   enable_rds    = true   → creates RDS (~$0.017/hr single-AZ)
#   enable_multi_az = true → adds standby (~$0.034/hr) — test briefly only
#
# TO PAUSE: terraform apply -var="enable_rds=false"
#   WARNING: This DESTROYS the instance. Take a manual snapshot first:
#   aws rds create-db-snapshot --db-instance-identifier Tag-BK-mysql \
#     --db-snapshot-identifier Tag-BK-mysql-manual-snap --region us-east-2
# ---------------------------------------------------------------------------
resource "aws_db_instance" "mysql" {
  count = var.enable_rds ? 1 : 0

  identifier        = "${lower(var.tag_name)}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  # Availability
  multi_az            = var.enable_multi_az
  publicly_accessible = false

  # Backups — automated daily snapshots sent to S3 backup bucket lifecycle
  backup_retention_period = var.db_backup_retention_days
  backup_window           = "03:00-04:00"   # UTC — low traffic window
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Snapshots
  skip_final_snapshot       = false
  final_snapshot_identifier = "${lower(var.tag_name)}-mysql-final-snap"
  copy_tags_to_snapshot     = true

  # Performance
  performance_insights_enabled = false   # costs extra — disable for lab

  # Prevent accidental destruction via Terraform
  deletion_protection = false   # flip to true in production

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Store RDS endpoint in SSM so EC2 instances can connect without hardcoding
# ---------------------------------------------------------------------------
resource "aws_ssm_parameter" "rds_endpoint" {
  count = var.enable_rds ? 1 : 0
  name  = "/global/rds_endpoint"
  type  = "String"
  value = aws_db_instance.mysql[0].endpoint

  tags = { Name = var.tag_name }
}
