variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "tag_name" {
  description = "Value for the Name tag applied to all resources"
  type        = string
  default     = "Tag-BK"
}

# ── Toggles (cost control) ───────────────────────────────────────────────────

variable "enable_rds" {
  description = "Create RDS instance — spin up for testing, destroy after (costs ~$0.017/hr)"
  type        = bool
  default     = false
}

variable "enable_multi_az" {
  description = "Enable RDS Multi-AZ standby — doubles cost (~$0.034/hr), test briefly only"
  type        = bool
  default     = false
}

variable "enable_efs" {
  description = "Create EFS filesystem — minimal cost but toggle off when not needed"
  type        = bool
  default     = true
}

# ── RDS ─────────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "appdb"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS storage in GB"
  type        = number
  default     = 20
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated RDS backups (0 = disabled)"
  type        = number
  default     = 7
}
