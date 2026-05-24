# ---------------------------------------------------------------------------
# Remote state — pull VPC outputs from Phase 2
# ---------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "kakkad-tf-state"
    key    = "VPC-Compute/terraform.tfstate"
    region = "us-east-2"
  }
}

# ---------------------------------------------------------------------------
# Latest Amazon Linux 2023 AMI (free-tier eligible, maintained by AWS)
# ---------------------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
