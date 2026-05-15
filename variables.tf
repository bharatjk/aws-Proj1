variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "admin_users" {
  description = "List of IAM usernames to add to the Admins group"
  type        = list(string)
  default     = ["bharat"]
}

variable "dev_users" {
  description = "List of IAM usernames to add to the Developers group"
  type        = list(string)
  default     = ["bob", "carol"]
}