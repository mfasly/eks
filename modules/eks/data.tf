data "aws_caller_identity" "current" {}

data "tls_certificate" "eks_oidc" {
  url        = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.eks]
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = [coalesce("", "amazon-eks-node-${coalesce(var.eks_version, "cluster_version")}-v*")]
  }

  most_recent = true
  owners      = ["amazon"]
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.id
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.id
}