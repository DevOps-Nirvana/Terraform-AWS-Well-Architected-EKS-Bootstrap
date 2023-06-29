#################
### Providers ###
#################

# This was setup with the latest release of terraform as of August 11, 2022
# You should use _exactly_ this version, not newer though because then anyone else using
# an older version will break
terraform {

  # Updated as of June 29, 2023
  required_version = "1.5.2"

  required_providers {
    # Latest as of June 29, 2023
    aws = {
      version = "~> 5.5.0"
    }
    local = {
      source = "hashicorp/local"
    }
    # Latest as of June 29, 2023
    random = {
      version = "~> 3.5.1"
    }
    # Latest as of June 29, 2023
    null = {
      version = "~> 3.2.1"
    }
    # Latest as of June 29, 2023
    external = {
      version = "~> 2.3.1"
    }
    # Latest as of June 29, 2023
    kubernetes = {
      version = "~> 2.21.1"
    }
    # Latest as of June 29, 2023
    # gitlab = {
    #   source = "gitlabhq/gitlab"
    #   version = "~> 16.1.0"
    # }
    # Add more here as/if needed...
  }
}

#################
### Variables ###
#################

variable "aws_account_ids" {
  type        = map
  description = "An list of the various AWS account ids, to more easily know across-account details for doing peered vpcs and such"
  default     = {
    "master" = "invalid"
  }
}

variable "global_cidrs" {
  type        = map
  description = "An list of the various AWS environments and their CIDRs"
  default     = {
    "master" = "0.0.0.0/16" # Use internal CIDRs, 10.x, 192.x, or 172.x.  Google for "subnetting" and private CIDRs.  Also always use /16 generally
  }
}

variable "client_name_short" {
  type        = string
  description = "The name of the client, customer, or subclient, should be 3 letters long"
}

variable "client_name" {
  type        = string
  description = "The full name of the client, customer, or subclient, can be up to 16 characters long ideally, any longer may run into naming issues when creating certain resources"
}

# Do not use if you can... ideally use AWS SSM instead.  May need for Windows instances though
# Note: recommended to store this key in a shared team storage in Keybase encrytped shared file storage
# variable "ssh_pub_key" {
# 	type        = string
# 	description = "The path to your SSH public key (for use in ec2 instance creation)"
# }

variable "environment" {
  type        = string
  description = "The name of the environment, eg dev, prod, staging, etc"
}

variable "subenvironment" {
  type        = string
  description = "The name of the subenvironment, only use if relevant"
  default     = ""
}

# We set a default here because we're primarily in the region us-east-1 as a company
# This can of course be overridden in a folder if some multi-regional deployments happen
variable "aws_region" {
  type        = string
  description = "AWS region (eg: us-east-2, eu-west-1, etc)"
  default     = "us-east-1"
}

# SHOULD BE THE SAME AS ABOVE, this is where our "terraform state" and global stacks live
# This one never changes, is hardcoded and (should) never be overwritten or defined as a different value
variable "master_aws_region" {
	type 		    = string
	description = "AWS region (eg: us-east-1, eu-west-1, etc)"
	default     = "us-east-1"
}

# Slack URL
variable "slack_webhook_url" {
  type        = string
  description = "Slack webhook URL"
  default     = "https://invalid-temp-replace-me.slack.com/services/XXXXXXXX/"
}

variable "slack_channel" {
  type        = string
  description = "The channel to send the SNS-to-Slack notifications (alerts) to"
  default     = "monitoring"
}

# This is for a "global" KMS key created per account generally, for admins
variable "kms_key_administrator_iam_arns" {
  description = "All CloudTrail Logs will be encrypted with a KMS Key (a Customer Master Key) that governs access to write API calls older than 7 days and all read API calls. The IAM Users specified in this list will have rights to change who can access this extended log data."
  type        = list(string)
  # example = ["arn:aws:iam::<aws-account-id>:user/<iam-user-name>"]
}

# And for users. usually copy/paste from above value for simpler setups
variable "kms_key_user_iam_arns" {
  description = "All CloudTrail Logs will be encrypted with a KMS Key (a Customer Master Key) that governs access to write API calls older than 7 days and all read API calls. The IAM Users specified in this list will have read-only access to this extended log data."
  type        = list(string)
  # example = ["arn:aws:iam::<aws-account-id>:user/<iam-user-name>"]
}

variable "global_users" {
  description = "The list of users to create (no access granted besides requiring MFA)"
  type        = list
  default     = []
}

variable "admin_users" {
  description = "The list of users to give admin to"
  type        = list
  default     = []
}

variable "billing_users" {
  description = "The list of users to give billing to"
  type        = list
  default     = []
}

# Users to allow access to assume into dev developer role
variable "dev_developer_users" {
  description = "The list of users to allow assuming into dev developer role"
  type        = list
  default     = []
}

# Users to allow access to assume into dev developer role
variable "dev_admin_users" {
  description = "The list of users to allow assuming into dev admin role"
  type        = list
  default     = []
}


####################
### Data Sources ###
####################

# data "aws_availability_zones" "available" {}

# This is a helper we'll use often to get our AWS account id, used in ARNs and such
data "aws_caller_identity" "current" {}

# Generic ec2 assume role policy used in many IAM roles
data "aws_iam_policy_document" "ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# This list was up-to-date as of November 29, 2022
# List was last updated from CloudFlare on April 8, 2021 - See: https://www.cloudflare.com/ips/
locals {
  cloudflare_ips_ipv4 = [
    "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/13", "104.24.0.0/14", "108.162.192.0/18",
    "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15", "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20",
    "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17"
  ]
  cloudflare_ips_ipv6 = [
    "2400:cb00::/32", "2606:4700::/32", "2803:f800::/32", "2405:b500::/32", "2405:8100::/32", "2a06:98c0::/29",
    "2c0f:f248::/32"
  ]
}
