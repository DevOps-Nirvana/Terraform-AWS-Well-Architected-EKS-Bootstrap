# Configure the GitLab Provider
# NOTE: Intentionally not setting the gitlab token here or anywhere.  This must be given by the user applying this on the command line interactively
variable "gitlab_token" {
  type        = string
}

provider "gitlab" {
  base_url = "https://gitlab.companynamezx.com/api/v4/"
  token = var.gitlab_token
}
