output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — open in browser to verify nginx"
  value       = try(aws_lb.web[0].dns_name, null)
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = try(aws_lb.web[0].arn, null)
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.web.id
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.web.latest_version
}

output "ami_id" {
  description = "AMI used by the Launch Template (Amazon Linux 2023)"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ec2_security_group_id" {
  description = "Security group ID attached to EC2 instances"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "cloudwatch_dashboard_url" {
  description = "Direct link to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.phase3.dashboard_name}"
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = aws_sns_topic.alarms.arn
}
