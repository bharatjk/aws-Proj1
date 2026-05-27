# ---------------------------------------------------------------------------
# Launch Template
# ---------------------------------------------------------------------------
resource "aws_launch_template" "web" {
  name_prefix   = "${var.tag_name}-web-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  # Attach key pair only when one is provided
  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  network_interfaces {
    associate_public_ip_address = false   # private subnet → direct SSH not possible
    security_groups             = [aws_security_group.ec2.id]
  }

  # Install nginx + EFS utils, mount EFS, serve instance metadata page
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y nginx amazon-efs-utils

    # ── EFS Auto-Mount ──────────────────────────────────────────────────────
    # HOW IT WORKS:
    # 1. Phase 4 creates the EFS filesystem and stores its ID in SSM at /global/efs_id
    # 2. Every new ASG instance runs this script on boot via user_data
    # 3. We read the EFS ID from SSM, create the mount point, and mount via NFS
    # 4. The /etc/fstab entry ensures EFS remounts automatically after reboot
    # 5. All ASG instances share the same EFS — files written by one instance
    #    are immediately visible to all others (shared persistent storage)
    # ────────────────────────────────────────────────────────────────────────
    EFS_ID=$(aws ssm get-parameter --name "/global/efs_id" --region ${var.aws_region} --query "Parameter.Value" --output text 2>/dev/null || echo "")

    if [ -n "$EFS_ID" ]; then
      mkdir -p /mnt/efs
      # Mount using amazon-efs-utils (handles TLS + automatic AZ-local mount target selection)
      mount -t efs -o tls $EFS_ID:/ /mnt/efs
      # Persist mount across reboots
      echo "$EFS_ID:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
    fi

    # ── IMDSv2 Metadata fetch (bash + curl) ─────────────────────────────────
    # Get IMDSv2 token first (required — IMDSv1 disabled by default on AL2023)
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 60")

    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)

    EFS_STATUS="Not mounted"
    if mountpoint -q /mnt/efs; then
      EFS_STATUS="Mounted ($EFS_ID)"
    fi

    # ── Write nginx index page ───────────────────────────────────────────────
    cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>ALB Routing Test</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .box { border: 2px solid #0275d8; padding: 20px; display: inline-block; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #0275d8; }
        .data { font-size: 1.2em; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="box">
        <h1>ALB Test Page</h1>
        <p class="data"><strong>Instance ID:</strong> $INSTANCE_ID</p>
        <p class="data"><strong>Availability Zone:</strong> $AZ</p>
        <p class="data"><strong>EFS Status:</strong> $EFS_STATUS</p>
    </div>
</body>
</html>
HTML

    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  # Encrypt the root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true   # detailed CloudWatch monitoring (1-min intervals)
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = var.tag_name }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { Name = var.tag_name }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = var.tag_name }
}
