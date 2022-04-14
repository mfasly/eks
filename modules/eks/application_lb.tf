resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_role.arn
    }
  }

  depends_on = [aws_eks_cluster.eks]
}

resource "helm_release" "aws-load-balancer-controller" {
  name         = "aws-load-balancer-controller"
  repository   = "https://aws.github.io/eks-charts"
  chart        = "aws-load-balancer-controller"
  namespace    = "kube-system"
  replace      = true
  force_update = true
  wait         = false

  set {
    name  = "clusterName"
    value = local.eks_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [kubernetes_service_account.service_account]
}