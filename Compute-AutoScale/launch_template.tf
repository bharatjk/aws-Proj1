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
        
        <?php
        // 1. Request an IMDSv2 Secure Token (Valid for 60 seconds)
        $token_options = [
            'http' => [
                'method' => 'PUT',
                'header' => 'X-aws-ec2-metadata-token-ttl-seconds: 60'
            ]
        ];
        $token_context = stream_context_create($token_options);
        $token = @file_get_contents('http://169.254.169', false, $token_context);

        if ($token) {
            // 2. Setup the header to use the retrieved token
            $data_options = [
                'http' => [
                    'method' => 'GET',
                    'header' => "X-aws-ec2-metadata-token: $token"
                ]
            ];
            $data_context = stream_context_create($data_options);

            // 3. Fetch the secure AWS Metadata
            $instance_id = @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id', false, $data_context);
            $az = @file_get_contents('http://169.254.169', false, $data_context);
            
            echo "<p class='data'><strong>Instance ID:</strong> " . htmlspecialchars($instance_id) . "</p>";
            echo "<p class='data'><strong>Availability Zone:</strong> " . htmlspecialchars($az) . "</p>";
        } else {
            // Fallback display if token fetching fails entirely
            echo "<p style='color: red;'><strong>Error:</strong> Unable to communicate with AWS IMDSv2.</p>";
            echo "<p><strong>Server Hostname:</strong> " . gethostname() . "</p>";
        }
        ?>
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
