#################
# Relevant variables exported incase others want to use them or embed them to something downstream
#################

# These two are relevant incase this is the stack that created the OIDC provider, so a secondary
# usage of this module is possible by specifying the oidc arn and url from another stack
output "oidc_arn" {
  value = local.oidc_arn
}
output "oidc_url" {
  value = local.oidc_url
}
output "aws_iam_policy_arn" {
  value = aws_iam_policy.default.arn
}

# This is the ARN of the role we created
output "arn" {
  value = aws_iam_role.default.arn
}

# This is the name of the role created (aka, the last part of the ARN).
# This is useful for tools which just need the role name directly not the full ARN
output "name" {
  value = aws_iam_role.default.name
}

# This is the policy we created, incase someone else wants to know/use it
output "policy_arn" {
  value = aws_iam_policy.default.arn
}
