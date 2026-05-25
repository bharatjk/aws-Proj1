# ═══════════════════════════════════════════════════════════════
# VARIABLES DEFINITION
# ═══════════════════════════════════════════════════════════════

variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for first public subnet (us-east-2a)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for second public subnet (us-east-2b)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for first private subnet (us-east-2a)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for second private subnet (us-east-2b)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_1" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-2a"
}

variable "availability_zone_2" {
  description = "Secondary availability zone"
  type        = string
  default     = "us-east-2b"
}

variable "my_ip" {
  description = "Your public IP address for SSH access (CIDR format: x.x.x.x/32)"
  type        = string
  default     = "104.148.209.220/32"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (WARNING: costs ~$32/month)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for monitoring network traffic"
  type        = bool
  default     = true
}
