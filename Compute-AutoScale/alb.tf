# ---------------------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------------------
resource "aws_lb" "web" {
  name               = "${var.tag_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  # Deploy across both public subnets (one per AZ for HA)
  subnets            = [data.terraform_remote_state.vpc.outputs.public_subnet_ids]  # Single subnet, accept AWS warning
  enable_deletion_protection = false  # flip to true in production

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Target Group — instances register here via ASG attachment
# ---------------------------------------------------------------------------
resource "aws_lb_target_group" "web" {
  name        = "${var.tag_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Listener — HTTP:80 → forward to target group
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = { Name = var.tag_name }
}
