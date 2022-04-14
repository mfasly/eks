locals {
  eks_cluster_name = join("-", [var.environment, var.project, var.cluster_name])
  user_data        = <<EOF
#!/bin/bash
set -ex
/etc/eks/bootstrap.sh ${local.eks_cluster_name} --b64-cluster-ca ${aws_eks_cluster.eks.certificate_authority[0].data} --apiserver-endpoint ${aws_eks_cluster.eks.endpoint}
EOF
  oicd_role_json_vars = {
    oidc_url   = trimprefix(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
    account_id = data.aws_caller_identity.current.id
  }
}

resource "aws_eks_cluster" "eks" {
  name     = local.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids)  
    security_group_ids      = concat(var.security_group_ids)
    endpoint_public_access  = var.eks_endpoint_public_access
    endpoint_private_access = var.eks_endpoint_private_access
  }

  tags = merge({
    Name = join("-", [var.environment, var.project, var.cluster_name])
  }, var.tags)

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_launch_template" "launch_template" {
  for_each = var.node_groups_configs

  name                   = join("-", [var.environment, var.project, each.key, "lt"])
  image_id               = lookup(each.value, "image_id", data.aws_ami.eks_worker.id)
  instance_type          = lookup(each.value, "instance_type")
  key_name               = lookup(each.value, "key_name", null)
  vpc_security_group_ids = var.node_group_security_ids != [] ? lookup(each.value, "node_group_security_ids", var.security_group_ids) : var.node_group_security_ids
  user_data              = base64encode(local.user_data)
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = lookup(each.value, "volume_size", 20)
      volume_type = lookup(each.value, "volume_type", "gp2")
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = join("-", [var.environment, var.project, each.key])
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = join("-", [var.environment, var.project, each.key])
    }
  }

  depends_on = [aws_eks_cluster.eks]
}


resource "aws_eks_node_group" "node_group" {
  for_each = var.node_groups_configs

  cluster_name    = local.eks_cluster_name
  node_group_name = join("-", [var.environment, var.project, each.key, "ng"])
  node_role_arn   = aws_iam_role.eks_cluster_node_role.arn
  subnet_ids      = var.private_subnet_ids

  launch_template {
    id      = lookup(aws_launch_template.launch_template[each.key], "id")
    version = lookup(aws_launch_template.launch_template[each.key], "latest_version")
  }

  scaling_config {
    desired_size = var.eks_desired_size
    max_size     = var.eks_max_size
    min_size     = var.eks_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_eks_cluster.eks, aws_iam_role.eks_cluster_node_role, aws_launch_template.launch_template]
}