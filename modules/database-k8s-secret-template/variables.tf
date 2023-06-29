# Terraform module input variables
variable "scheme" {
  description = "The scheme of the db.  Typically 'mysql' or 'postgres'"
}

variable "hostname" {
  description = "The database hostname"
}

variable "port" {
  description = "The port to connect to"
}

variable "username" {
  description = "The database username we will authenticate as"
}

variable "password" {
  description = "The database password we will authenticate with the username"
}

variable "database" {
  description = "The database we will connect to, if empty defaults to username"
  default     = ""
}

variable "database_uri_options" {
  description = "options to put after the database_uri"
  default     = ""
}

variable "jdbc_uri_options" {
  description = "options to put after the jdbc_uri"
  default     = ""
}