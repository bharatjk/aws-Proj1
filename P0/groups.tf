# ── Admins group ──────────────────────────────────────────
resource "aws_iam_group" "admins" {
  name = "Admins"
}

resource "aws_iam_group_policy_attachment" "admins_policy" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ── Developers group ──────────────────────────────────────
resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# ── ReadOnly group ────────────────────────────────────────
resource "aws_iam_group" "readonly" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy_attachment" "readonly_policy" {
  group      = aws_iam_group.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}