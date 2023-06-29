# ADMINS
resource "aws_iam_group" "admins" {
  name = "admins"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "admins" {
  group = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_group_membership" "admins" {
  for_each = toset(var.admin_users)
  user = each.key
  groups = [
    aws_iam_group.admins.name,
  ]
  depends_on = [aws_iam_user.users,aws_iam_group_policy_attachment.admins]
}
