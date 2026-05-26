# ---------------------------------------------------------------------------
# Auto Scaling Group
# ---------------------------------------------------------------------------
resource "aws_autoscaling_group" "web" {
  name = "${var.tag_name}-asg"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  # Spread instances across private subnets (one per AZ)

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Register with ALB target group
  target_group_arns = [aws_lb_target_group.web.arn]

  # Use ELB health checks so unhealthy instances get replaced
  health_check_type         = "ELB"
  health_check_grace_period = 120   # seconds — wait for nginx to start

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Rolling instance refresh when launch template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = var.tag_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# Scale-Out Policy — add 1 instance when CPU is high
# ---------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.tag_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300   # seconds before another scale-out
  policy_type            = "SimpleScaling"
}

# ---------------------------------------------------------------------------
# Scale-In Policy — remove 1 instance when CPU is low
# ---------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.tag_name}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}
