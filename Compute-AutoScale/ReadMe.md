File        	        What it does
backend.tf	        S3 state at Phase3-Compute/terraform.tfstate, same DynamoDB lock
data.tf	            Pulls Phase 2 VPC outputs via remote state; auto-fetches latest AL2023 AMI
security_groups.tf	ALB SG (0.0.0.0/0 → 80/443) + EC2 SG (ALB only → 80, your IP → 22)
iam.tf	            EC2 instance role with SSM + CloudWatch agent policies
launch_template.tf	AL2023 + nginx via user_data, encrypted gp3 root, detailed monitoring
alb.tf	            Internet-facing ALB, target group with health checks, HTTP listener
asg.tf	            ASG across public subnets, ELB health checks, rolling instance refresh, scale-out/in policies
cloudwatch.tf	    4 alarms (CPU high/low, 5xx errors, healthy host count) + dashboard + optional SNS email
outputs.tf	        ALB DNS, dashboard URL, ASG name, AMI ID
variables.tf	    All tunables with safe defaults
terraform.tfvars	Fill in your IP, copy to terraform.tfvars
