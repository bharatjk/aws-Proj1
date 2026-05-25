# Phase 2 Outputs — VPC-Compute
# These outputs are read by Phase 3 (Compute-AutoScale) via remote state

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "security_group_ssh_id" {
  description = "Security group for SSH access"
  value       = aws_security_group.ssh.id
}

output "security_group_web_id" {
  description = "Security group for web traffic"
  value       = aws_security_group.web.id
}

output "security_group_app_id" {
  description = "Security group for app tier"
  value       = aws_security_group.app.id
}

output "security_group_database_id" {
  description = "Security group for database tier"
  value       = aws_security_group.database.id
}

output "nat_gateway_ip" {
  description = "NAT Gateway Elastic IP (if NAT is enabled)"
  value       = try(aws_eip.nat[0].public_ip, null)
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = try(aws_internet_gateway.main.id, null)
}
