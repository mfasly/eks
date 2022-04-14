output "eks_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.eks.endpoint
}

output "id" {
  description = "The id of the EKS cluster."
  value       = aws_eks_cluster.eks.id
}

output "node_role_arn" {
  description = "EKS Cluster Node role ARN"
  value       = aws_iam_role.eks_cluster_node_role.arn
}