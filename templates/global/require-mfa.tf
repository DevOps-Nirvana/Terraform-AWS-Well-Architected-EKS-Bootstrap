
# This comes from: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_iam_mfa-selfmanage.html
# With some additions to view their own security and IAM-related objects
# Our IAM Policy to only allow us access to ONLY this bucket
data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid    = "AllowListUsersAllIfMFA"
    effect = "Allow"
    actions = [
        "iam:ListUsers",
        "access-analyzer:ListPolicyGenerations",
        "iam:ListGroups",
        "iam:GetServiceLastAccessedDetails",
        "iam:ListGroupPolicies",
        "iam:ListAttachedGroupPolicies",
        "iam:ListPolicies",
        "iam:GetPolicyVersion",
        "iam:GetGroup",
    ]
    resources = ["*"]
    condition {
        test = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values = [
            "true",
        ]
    }
  }

  statement {
    sid    = "AllowIndividualUserToDescribeTheirOwnMFAAndSecurityObjects"
    effect = "Allow"
    actions = [
        "iam:ListUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListAttachedUserPolicies",
        "iam:ListPoliciesGrantingServiceAccess",
        "iam:ListUserTags",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:ListVirtualMFADevices",
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice",
        "iam:ListAccessKeys",
        "iam:ListSigningCertificates",
        "iam:getUser",
        "iam:ListSSHPublicKeys",
        "iam:ListServiceSpecificCredentials",
        "iam:GetSSHPublicKey",
        "iam:ListMFADevices",
    ]
    resources = [
        "arn:aws:iam::*:mfa/$${aws:username}",
        "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToManageTheirOwnMFAWhenUsingMFA"
    effect = "Allow"
    actions = [
        "iam:DeactivateMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:CreateAccessKey",
        "iam:UpdateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UploadSigningCertificate",
        "iam:UpdateSigningCertificate",
        "iam:DeleteSigningCertificate",
        "iam:UploadSSHPublicKey",
        "iam:DeleteSSHPublicKey",
        "iam:CreateServiceSpecificCredential",
        "iam:UpdateServiceSpecificCredential",
        "iam:ResetServiceSpecificCredential",
        "iam:DeleteServiceSpecificCredential",
    ]
    resources = [
        "arn:aws:iam::*:mfa/$${aws:username}",
        "arn:aws:iam::*:user/$${aws:username}"
    ]

    condition {
        test = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values = [
            "true",
        ]
    }
  }

  statement {
    sid    = "BlockMostAccessUnlessSignedInWithMFA"
    effect = "Deny"
    not_actions = [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "iam:ChangePassword",
        "iam:ListSigningCertificates",
        "iam:ListAccessKeys",
        "iam:getUser",
        "iam:ListSSHPublicKeys",
        "iam:ListServiceSpecificCredentials",
    ]
    resources = ["*"]

    condition {
        test = "BoolIfExists"
        variable = "aws:MultiFactorAuthPresent"
        values = [
            "false",
        ]
    }
  }

}

# SHOULD NOT USE ROLES, SHOULD USE GROUPS, BUT LEFT THIS HERE IF YOU WANT TO USE ROLES INSTEAD
# resource "aws_iam_role" "require_mfa" {
#   name = "require_mfa"
#   path = "/"
#   assume_role_policy = "${data.aws_iam_policy_document.allow_assume_role_if_mfa.json}"
#   max_session_duration = "${var.max_session_duration}"
# }


resource "aws_iam_policy" "require_mfa" {
  name = "require_users_to_mfa"
  description = "This helps require users to MFA and allows them to self manage it"
  policy      = data.aws_iam_policy_document.require_mfa.json
}


resource "aws_iam_group" "require_mfa" {
  name = "require_mfa"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "require_mfa" {
  group = aws_iam_group.require_mfa.name
  policy_arn = aws_iam_policy.require_mfa.arn
}
