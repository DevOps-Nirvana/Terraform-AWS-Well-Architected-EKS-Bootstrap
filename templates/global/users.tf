# Create all users we wish to create
resource "aws_iam_user" "users" {
  for_each = toset(var.global_users)
  name = each.key
  tags = merge( module.terraform_tags.tags_no_name,{ "Name" = each.key } )
}

# Require MFA for all users
resource "aws_iam_user_group_membership" "require_mfa" {
  for_each = toset(var.global_users)
  user = each.key
  groups = [
    aws_iam_group.require_mfa.name,
  ]
  depends_on = [aws_iam_user.users]
}
