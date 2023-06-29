#######################################
# Stack: password-policy
# Purpose: Sets the password policy of an AWS Account (globally)
#######################################

######### Input Variables #########

variable "minimum_password_length" {
  description = "Minimum length to require for user passwords."
  type        = number
  default     = 12
}

variable "require_numbers" {
  description = "Whether to require numbers for user passwords (true or false)."
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Whether to require symbols for user passwords (true or false)."
  type        = bool
  default     = true
}

variable "require_lowercase_characters" {
  description = "Whether to require lowercase characters for user passwords (true or false)."
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Whether to require uppercase characters for user passwords (true or false)."
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Whether to allow users to change their own password (true or false)."
  type        = bool
  default     = true
}

variable "hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired (i.e. require administrator reset) (true or false).  Disabled by default because we aren't going to use password expiration features"
  type        = bool
  default     = false
}

variable "max_password_age" {
  description = "The number of days that an user password is valid. Enter 0 for no expiration.  Up-to-date NIST standards state that with 2FA enabled and the era of password managers you should not use password expiration features.  So this is disabled now by default"
  type        = number
  default     = 0
}

variable "password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing."
  type        = number
  default     = 9
}

######### Resource definitions #########

# Define the IAM User password policy
resource "aws_iam_account_password_policy" "main" {
  minimum_password_length        = var.minimum_password_length
  require_numbers                = var.require_numbers
  require_symbols                = var.require_symbols
  require_lowercase_characters   = var.require_lowercase_characters
  require_uppercase_characters   = var.require_uppercase_characters
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  password_reuse_prevention      = var.password_reuse_prevention
}
