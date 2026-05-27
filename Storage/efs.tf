# ---------------------------------------------------------------------------
# EFS Filesystem
# ---------------------------------------------------------------------------
# HOW AUTO-MOUNT WORKS:
# 1. EFS filesystem is created here with mount targets in each private subnet
# 2. A security group allows NFS traffic (port 2049) from EC2 instances
# 3. The EFS filesystem ID is stored in SSM so Phase 3 launch template can read it
# 4. Phase 3 launch template user_data installs amazon-efs-utils and mounts
#    the filesystem at /mnt/efs on every new ASG instance automatically
# 5. All ASG instances share the same EFS — files written by one instance
#    are immediately visible to all others (shared persistent storage)
# ---------------------------------------------------------------------------

resource "aws_efs_file_system" "main" {
  count            = var.enable_efs ? 1 : 0
  creation_token   = "${var.tag_name}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Mount targets — one per private subnet (one per AZ)
# EFS needs a mount target in each AZ where EC2 instances run
# ---------------------------------------------------------------------------
resource "aws_efs_mount_target" "private1" {
  count           = var.enable_efs ? 1 : 0
  file_system_id  = aws_efs_file_system.main[0].id
  subnet_id       = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  security_groups = [aws_security_group.efs[0].id]
}

resource "aws_efs_mount_target" "private2" {
  count           = var.enable_efs ? 1 : 0
  file_system_id  = aws_efs_file_system.main[0].id
  subnet_id       = data.terraform_remote_state.vpc.outputs.private_subnet_ids[1]
  security_groups = [aws_security_group.efs[0].id]
}

# ---------------------------------------------------------------------------
# EFS Security Group — allow NFS only from EC2 security group
# ---------------------------------------------------------------------------
resource "aws_security_group" "efs" {
  count       = var.enable_efs ? 1 : 0
  name        = "${var.tag_name}-efs-sg"
  description = "Allow NFS from EC2 instances only"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description     = "NFS from EC2 instances"
    from_port       = 2049
    to_port         = 2049
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
# Store EFS ID in SSM so Phase 3 launch template can read it for auto-mount
# ---------------------------------------------------------------------------
resource "aws_ssm_parameter" "efs_id" {
  count = var.enable_efs ? 1 : 0
  name  = "/global/efs_id"
  type  = "String"
  value = aws_efs_file_system.main[0].id

  tags = { Name = var.tag_name }
}
