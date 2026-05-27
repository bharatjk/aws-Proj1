output "efs_id" {
  description = "EFS filesystem ID — used in launch template for auto-mount"
  value       = try(aws_efs_file_system.main[0].id, null)
}

output "efs_dns_name" {
  description = "EFS DNS name for manual mount commands"
  value       = try(aws_efs_file_system.main[0].dns_name, null)
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint — connect via EC2 instances in private subnet"
  value       = try(aws_db_instance.mysql[0].endpoint, null)
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = try(aws_db_instance.mysql[0].port, null)
}

output "rds_db_name" {
  description = "MySQL database name"
  value       = try(aws_db_instance.mysql[0].db_name, null)
}
