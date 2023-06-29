# Lookup our env cluster info
data "aws_eks_cluster" "this" {
  name = var.environment # This is typically the same name as the env, one cluster per env (per aws account)
}

data "aws_eks_cluster_auth" "this" {
  name = var.environment # This is typically the same name as the env, one cluster per env (per aws account)
}

# Connect to our "dev" kubernetes cluster with the above data
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
