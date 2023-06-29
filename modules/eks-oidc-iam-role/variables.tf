#################
# Inputs from the user when defining this module
#################

# Required Inputs
variable "name" {
  description = "The name of the IAM role to be created (is used as a prefix)"
  type        = string
}
variable "eks_cluster_name" {
  description = "The name of the EKS cluster to be granted access to"
  type        = string
}
variable "aws_iam_policy_json" {
  description = "The .json of an aws_iam_policy_document data object"
  type        = string
}

# Optional inputs with sane defaults
variable "role_policy_template" {
  description = "This must be either 'all' or 'conditional' and defines which assume role template we are using.  The conditional is the default because it is least-permissive"
  type        = string
  default     = "conditional"
}
variable "role_policy_namespace" {
  description = "If role_policy_template is conditional, this must be set, will default to something sane though, such as the default namespace"
  type        = string
  default     = "default"
}
variable "role_policy_service_account" {
  description = "If role_policy_template is conditional, this must be set.  Will default to empty string to prevent errors in compilation without it, but it will fail to execute if not set"
  type        = string
  default     = ""
}
variable "eks_oidc_arn" {
  description = "The ARN of the OIDC provider to use.  If not specified it will create one"
  type        = string
  default     = ""
}
variable "eks_oidc_url" {
  description = "The URL of the OIDC provider to use.  If not specified it will create one (related to arn right above)"
  type        = string
  default     = ""
}
variable "region" {
  description = "The AWS Region, default for is us-east-2"
  type        = string
  default     = "us-east-2"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

#################
# Inputs from other sources (external scripts / aws apis)
#################
# This grabs a SSL thumbprint from AWS's on a per-region basis
data "external" "thumbprint" {
  program = ["${path.module}/thumbprint.sh", var.region]
}

# This pulls data from the EKS cluster (NOTE: only works if we have access to the cluster, not across accounts)
data "aws_eks_cluster" "default" {
  count = length(var.eks_oidc_arn) > 0 ? 0 : 1
  name = var.eks_cluster_name
}

locals {
  # This "trick" will either by default choose the var.eks_oidc_arn/url if it's specified, if not
  # it will cascade into the optional OIDC provider that it automatically created
  oidc_arn = coalesce(
      var.eks_oidc_arn,
      element(
        concat(
          aws_iam_openid_connect_provider.default.*.arn,
          [""],
        ),
        0,
      ),
      "not-set"
    )

  oidc_url = replace(
    coalesce(
      var.eks_oidc_url,
      element(
        concat(
          aws_iam_openid_connect_provider.default.*.url,
          [""],
        ),
        0,
      ),
      "not-set"
    ), "https://", "")

}
