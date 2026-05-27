# ---------------------------------------------------------------------------
# Remote state from Phase 3 — EC2 security group ID for EFS and RDS ingress
# ---------------------------------------------------------------------------
data "terraform_remote_state" "phase3" {
  backend = "s3"
  config = {
    bucket = "kakkad-tf-state"
    key    = "Phase3-Compute/terraform.tfstate"
    region = "us-east-2"
  }
}
