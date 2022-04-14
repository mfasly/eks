resource "aws_iam_role" "eks_cluster_role" {
  name = join("-", [var.environment, var.project, "eks-cluster-role"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          "Service" : "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_iam_role" "eks_cluster_node_role" {
  name = join("-", [var.environment, var.project, "eks-cluster-node-role"])

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

  depends_on = [aws_iam_role.eks_cluster_node_role]
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  depends_on = [aws_iam_role.eks_cluster_node_role]
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

  depends_on = [aws_iam_role.eks_cluster_node_role]
}

resource "aws_iam_openid_connect_provider" "iam_openid_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "alb_policy" {
  name        = join("-", [var.environment, var.project, "AWSLoadBalancerControllerIAMPolicy"])
  description = "AWSLoadBalancerControllerIAMPolicy"
  policy      = file("${path.module}/iam_policy_files/iam_policy.json")
}

resource "aws_iam_role" "alb_role" {
  name               = join("-", [var.environment, var.project, "eks-cluster-alb-role"])
  assume_role_policy = templatefile("${path.module}/templates/oicd_trust_elationship.json.tftpl", local.oicd_role_json_vars)
}

resource "aws_iam_role_policy_attachment" "alb_policy" {
  role       = aws_iam_role.alb_role.name
  policy_arn = aws_iam_policy.alb_policy.arn

  depends_on = [aws_iam_role.alb_role]
}