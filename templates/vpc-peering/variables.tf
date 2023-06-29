# Every stack has a name and a version, this is used in all the tags
locals {
  # The unique name of this stack.  This is typically copied from the folder name
  stack_name = "vpc-peering"
  # The version of this stack name, should always be 3 octets, major.minor.sub
  stack_version = "1.0.0"
}

# A helper module which generates our standardized tags for all objects
module "terraform_tags" {
  source = "../../../modules/terraform-tags"
  name   = local.stack_name
  stage  = var.environment
  tags   = tomap({ "StackVersion" = local.stack_version })
}

# [Mandatory] Define whether we are requesting or accepting the peering connection
variable "peering_type" {
  type        = string
  description = "Which end of the peering connection we represent ('requester' or 'accepter')"

  validation {
    condition     = length(regexall("^(requester|accepter)$", var.peering_type)) > 0
    error_message = "ERROR: Valid peering types are 'requester' and 'accepter'."
  }
}

# [Mandatory] Which environments hold the vpcs we wish to peer with
variable "peer_environments" {
  type = map(object({
    region = string
  }))
  description = "The environments holding the VPCs to be peered with"
}

# This pulls in our remote vpc stack variables from our project/stage/region vpc
data "terraform_remote_state" "vpc_this" {
  backend = "s3"
  config = {
    bucket = "terraform-deploy-fragments-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
    key    = "${var.client_name_short}-${var.environment}-${var.subenvironment != "" ? format("%s-", var.subenvironment) : ""}vpc.tfstate"
    region = var.aws_region
  }
}

# This pulls in the target remote vpc stack variables from our project/stage/region vpc
data "terraform_remote_state" "vpc_peers" {
  for_each = var.peering_type == "requester" ? var.peer_environments : {}
  backend  = "s3"
  config = {
    bucket = "terraform-deploy-fragments-${var.aws_account_ids[each.key]}-${each.value.region}"
    key    = "${var.client_name_short}-${each.key}-vpc.tfstate"
    region = each.value.region
  }
}

# This pulls in the target remote vpc-peering stack variables from our project/stage/region vpc
data "terraform_remote_state" "vpc_peerings" {
  for_each = var.peering_type == "accepter" ? var.peer_environments : {}
  backend  = "s3"
  config = {
    bucket = "terraform-deploy-fragments-${var.aws_account_ids[each.key]}-${each.value.region}"
    key    = "${var.client_name_short}-${each.key}-vpc-peering.tfstate"
    region = each.value.region
  }
}
