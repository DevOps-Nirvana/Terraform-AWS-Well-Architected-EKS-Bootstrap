# Billing
resource "aws_iam_group" "billing" {
  name = "billing"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "billing" {
  group = aws_iam_group.billing.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

# resource "aws_iam_group_policy_attachment" "billing_full_access" {
#   group = aws_iam_group.billing.name
#   policy_arn = "arn:aws:iam::408424590394:policy/BillingFullAccess"
# }

resource "aws_iam_user_group_membership" "billing" {
  for_each = toset(var.billing_users)
  user = each.key
  groups = [
    aws_iam_group.billing.name,
  ]
  depends_on = [aws_iam_user.users,aws_iam_group_policy_attachment.billing]
}
