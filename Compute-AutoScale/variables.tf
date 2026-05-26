variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# ── Instance ────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"   # free-tier eligible
}

#We have not created a key pair yet
variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}

# ── ASG ─────────────────────────────────────────────────────────────────────

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

# ── Scaling thresholds ───────────────────────────────────────────────────────

variable "cpu_scale_out_threshold" {
  description = "CPU % that triggers scale-out"
  type        = number
  default     = 70
}

variable "cpu_scale_in_threshold" {
  description = "CPU % that triggers scale-in"
  type        = number
  default     = 30
}

# ── Tags ─────────────────────────────────────────────────────────────────────

variable "tag_name" {
  description = "Value for the Name tag applied to all resources"
  type        = string
  default     = "Tag-BK"
}
