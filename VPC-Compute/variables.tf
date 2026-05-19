# ═══════════════════════════════════════════════════════════════
# VARIABLES DEFINITION
# ═══════════════════════════════════════════════════════════════
# Variables make your Terraform code reusable and configurable.
# You can override defaults when running terraform apply:
#   terraform apply -var="aws_region=us-west-2"
# ═══════════════════════════════════════════════════════════════

# ── AWS Region ─────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-2"  # Ohio - change this if needed
}

# ── VPC CIDR Block ─────────────────────────────────────────────
# CIDR (Classless Inter-Domain Routing) defines the IP address range
# 10.0.0.0/16 means:
#   - Network: 10.0.0.0
#   - Subnet mask: /16 (first 16 bits are network, last 16 are hosts)
#   - Available IPs: 10.0.0.0 to 10.0.255.255 (65,536 addresses)
#   - Usable for hosts: 65,531 (AWS reserves 5 per subnet)
variable "vpc_cidr" {
  description = "CIDR block for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ── Public Subnet CIDR ─────────────────────────────────────────
# 10.0.1.0/24 means:
#   - Network: 10.0.1.0
#   - Subnet mask: /24 (first 24 bits network, last 8 for hosts)
#   - Available IPs: 10.0.1.0 to 10.0.1.255 (256 addresses)
#   - Usable: 251 (AWS reserves 5: .0, .1, .2, .3, .255)
# This subnet will have public internet access via Internet Gateway
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (internet-facing resources)"
  type        = string
  default     = "10.0.1.0/24"
}

# ── Private Subnet CIDR ────────────────────────────────────────
# 10.0.2.0/24 = 256 IPs (251 usable)
# This subnet will have NO direct internet access
# Outbound internet goes through NAT Gateway in public subnet
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (internal resources only)"
  type        = string
  default     = "10.0.2.0/24"
}

# ── Availability Zone ──────────────────────────────────────────
# AWS regions have multiple availability zones (data centers)
# us-east-2 has: us-east-2a, us-east-2b, us-east-2c
# We pick one AZ for simplicity (production would span multiple AZs)
variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-2a"
}

# ── Your Public IP ─────────────────────────────────────────────
# Security groups will use this to restrict SSH access to only YOUR computer
# Find your IP: curl ifconfig.me
# Format must be CIDR: x.x.x.x/32 (the /32 means exactly this one IP)
variable "my_ip" {
  description = "Your public IP address for SSH access (MUST be in CIDR format: x.x.x.x/32)"
  type        = string
  default     = "104.148.209.220/32"
}

# ── NAT Gateway Toggle ─────────────────────────────────────────
# NAT Gateway costs money: $0.045/hour = ~$32/month + data transfer
# Set to false to skip NAT Gateway creation (saves money but private subnet can't reach internet)
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway (WARNING: costs ~$32/month)"
  type        = bool
  default     = false  # Set to true only when you need it
}