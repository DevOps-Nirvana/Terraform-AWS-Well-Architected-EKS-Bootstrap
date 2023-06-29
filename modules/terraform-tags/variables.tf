# Terraform module input variables
variable "name" {
  description = "Optional solution name, e.g. 'app' or 'web' or 'db', include the number if more than one, eg: web1"
  type        = string
  default      = ""
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'stg', 'dev', 'beta', 'test'"
  type        = string
  default     = ""
}

variable "client" {
  description = "Client name 3-letter abbreviation, defaults to czx for companynamezx"
  type        = string
  default     = "czx"
}

variable "delimiter" {
  description = "Delimiter to be used between strings, typically is -, optionally set to empty string for windows hostnames and such"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to tack onto this object (e.g. `map('Purpose`,`webserver`)"
  type        = map
  default     = {}
}
