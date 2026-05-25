# ---------------------------------------------------------------------------
# Security Group — Application Load Balancer
# ---------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.tag_name}-alb-sg"
  description = "Allow HTTP/HTTPS inbound to ALB from the internet"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Security Group — EC2 instances (behind ALB)
# ---------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.tag_name}-ec2-sg"
  description = "Allow HTTP from ALB only; SSH from /global/my_ip SSM parameter"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # nginx traffic — only from ALB SG
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH — IP pulled from SSM /global/my_ip
  ingress {
    description = "SSH from operator IP (SSM /global/my_ip)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_ssm_parameter.my_ip.value]
  }

  egress {
    description = "All outbound (yum updates, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = var.tag_name }
}
