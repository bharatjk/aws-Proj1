# In VPC-Compute/main.tf
data "terraform_remote_state" "phase2" {
  backend = "s3"
  config = {
    bucket = "kakkad-tf-state"
    key    = "phase2/terraform.tfstate"
    region = "us-east-2"
  }
}

# Now you can reference Phase 1 outputs:
# data.terraform_remote_state.phase1.outputs.ec2_instance_profile_name