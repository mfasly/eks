locals {
  cluster_name = join("-", [var.environment, var.project, var.eks_cluster_name])
  common_tags = {
    join("/", ["kubernetes.io/cluster", local.cluster_name]) = "owned"
  }
}