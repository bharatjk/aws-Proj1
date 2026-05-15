# ── Account password policy ───────────────────────────────
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}

# ── MFA enforcement policy (attached to all groups) ───────
resource "aws_iam_policy" "mfa_enforce" {
  name        = "EnforceMFA"
  description = "Deny all actions unless MFA is active"
  policy      = file("${path.module}/policies/mfa_enforce.json")
}

resource "aws_iam_group_policy_attachment" "admins_mfa" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.mfa_enforce.arn
}

resource "aws_iam_group_policy_attachment" "developers_mfa" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.mfa_enforce.arn
}

# ── IAM users ─────────────────────────────────────────────
# below user will be added to the Admins group via aws_iam_group_membership resource
resource "aws_iam_user" "admins" {
  for_each = toset(var.admin_users)
  name     = each.value
  tags     = { Group = "Admins" }
}
resource "aws_iam_user" "developers" {
  for_each = toset(var.dev_users)
  name     = each.value
  tags     = { Group = "Developers" }
}

# ── Add users to groups ───────────────────────────────────
resource "aws_iam_group_membership" "admins" {
  name  = "admins-membership"
  group = aws_iam_group.admins.name
  users = [for u in aws_iam_user.admins : u.name]
}

resource "aws_iam_group_membership" "developers" {
  name  = "developers-membership"
  group = aws_iam_group.developers.name
  users = [for u in aws_iam_user.developers : u.name]
}