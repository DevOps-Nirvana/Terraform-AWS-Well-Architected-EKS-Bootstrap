###########################################################################
# Stack: account-alias.tf                                                 #
# Purpose: Sets up an AWS account alias, to be able to easily tell the    #
#          various aws accounts apart.  This is considered best practice  #
###########################################################################

######### Input Variables #########

variable "account_alias" {
  description = "AWS IAM account alias for this account"
  type        = string
  default     = ""
}

locals {
  # Automatically get the port based on the engine
  account_alias = length(var.account_alias) > 0 ? var.account_alias : "${var.client_name}-${var.environment}"
}

######### Resource definitions #########

resource "aws_iam_account_alias" "this" {
  account_alias = local.account_alias
}
