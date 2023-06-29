variable "aws_efs_enable_encryption" {
  description = "Whether or not we want to encrypt EFS"
  type        = bool
  default     = true
}

resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs-${var.subenvironment != "" ? var.subenvironment : var.environment}"
  encrypted      = var.aws_efs_enable_encryption == true ? true : false

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = module.terraform_tags.tags
}


resource "aws_security_group" "efs" {
  name        = module.terraform_tags.id
  description = "${module.terraform_tags.id} allow all from local"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "nfs for efs"
    cidr_blocks = [var.global_cidrs[ var.subenvironment != "" ? var.subenvironment : var.environment ]]
  }

}

# iterate/loop through all private subnets
resource "aws_efs_mount_target" "efs" {
  for_each        = toset(data.terraform_remote_state.vpc.outputs.private_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs.id]
}

output "efs_filesystem_id" {
  value = aws_efs_file_system.efs.id
}
