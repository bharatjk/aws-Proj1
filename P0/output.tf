output "admins_group_arn" {
  value = aws_iam_group.admins.arn
}

output "developers_group_arn" {
  value = aws_iam_group.developers.arn
}

output "ec2_instance_profile_name" {
  description = "Use this in Phase 3 when launching EC2 instances"
  value       = aws_iam_instance_profile.ec2_s3_reader.name
}