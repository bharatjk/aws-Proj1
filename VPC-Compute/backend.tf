# ═══════════════════════════════════════════════════════════════
# BACKEND CONFIGURATION
# ═══════════════════════════════════════════════════════════════
# This file configures where Terraform stores its state and which
# AWS provider version to use.
#
# State is stored in S3 (from Phase 0) so multiple people/machines
# can work on the same infrastructure without conflicts.
# ═══════════════════════════════════════════════════════════════

terraform {
  # Require Terraform version 1.0 or higher
  required_version = ">= 1.0"

  # Specify which providers we need
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Official AWS provider
      version = "~> 5.0"          # Use any 5.x version (5.1, 5.2, etc.)
    }
  }

  # Remote state backend configuration
  # This points to the S3 bucket you created in Phase 0
  backend "s3" {
    bucket         = "kakkad-tf-state"           # Your S3 bucket name
    key            = "phase2/terraform.tfstate"   # Path within bucket for this project's state
    region         = "us-east-2"                  # Ohio region
    dynamodb_table = "tf-state-lock"              # Prevents concurrent terraform runs
    encrypt        = true                         # Encrypt state at rest
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Region is set via variables (us-east-2)

  # Default tags applied to ALL resources created by this Terraform project
  # This makes it easy to identify and filter resources later
  default_tags {
    tags = {
      Name        = "Tag-BK"               # Your custom naming requirement
      Project     = "AWS-Learning"         # What project this belongs to
      Phase       = "Phase2-Networking"    # Which phase
      ManagedBy   = "Terraform"            # How it was created
      Environment = "Learning"             # What environment (dev/prod/learning)
    }
  }
}