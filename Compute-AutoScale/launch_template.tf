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
    associate_public_ip_address = true   # public subnet → direct SSH possible
    security_groups             = [aws_security_group.ec2.id]
  }

  # Install nginx and serve a simple health-check page
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y nginx

    # Write a simple branded index page
    cat > /usr/share/nginx/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
      <head><title>Phase 3 — Tag-BK</title></head>
      <body style="font-family:sans-serif;text-align:center;padding:60px">
        <h1>&#x2705; Phase 3 Running</h1>
        <p>Instance ID: <strong>$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</strong></p>
        <p>AZ: <strong>$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</strong></p>
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
      volume_size           = 20
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
