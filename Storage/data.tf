# ---------------------------------------------------------------------------
# Remote state from Phase 2 — VPC IDs and subnet IDs
# ---------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "kakkad-tf-state"
    key    = "phase2/terraform.tfstate"
    region = "us-east-2"
  }
}

# ---------------------------------------------------------------------------
# SSM Parameters — RDS credentials
# ---------------------------------------------------------------------------
data "aws_ssm_parameter" "db_username" {
  name = "/global/db_username"
}

data "aws_ssm_parameter" "db_password" {
  name            = "/global/db_password"
  with_decryption = true
}
