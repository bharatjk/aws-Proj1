# ---------------------------------------------------------------------------
# IAM Policy — read SSM parameters under /global/*
# Attach this to any role that needs access to global parameters:
#   - GitHub Actions OIDC role (CI/CD)
#   - EC2 instance role (if app needs to read params at runtime)
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "ssm_global_read" {
  name        = "${var.tag_name}-ssm-global-read"
  description = "Allow reading SSM Parameter Store values under /global/ path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMGlobalRead"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/global/*"
      }
    ]
  })

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# Attach the policy to the EC2 instance role (defined in iam.tf)
# so instances can also read /global/* at runtime if needed
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2_ssm_global" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ssm_global_read.arn
}

# ---------------------------------------------------------------------------
# Output the policy ARN — attach this manually to your GitHub Actions
# OIDC role so terraform plan/apply can read /global/my_ip during CI
# ---------------------------------------------------------------------------
output "ssm_global_read_policy_arn" {
  description = "Attach this policy ARN to your GitHub Actions OIDC role"
  value       = aws_iam_policy.ssm_global_read.arn
}
