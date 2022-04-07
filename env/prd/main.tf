provider "aws" {
  region = var.region
}

#resource "aws_dynamodb_table" "basic-dynamodb-table" {
#  name           = "state_lock"
#  read_capacity  = "10"
#  write_capacity = "10"
#  hash_key       = "UserId"
#
#  attribute {
#    name = "UserId"
#    type = "S"
#  }
#
#  tags = {
#    Name        = "dynamodb-table-1"
#    Environment = "production"
#  }
#}

module "vpc" {
  source          = "../../modules/vpc"
  environment     = var.environment
  project         = var.project
  cidr_block      = var.cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  common_tags     = local.common_tags
}

module "eks_public_security_group" {
  source              = "../../modules/security_group"
  aws_vpc_id          = module.vpc.vpc_id
  description         = "public security group"
  environment         = var.environment
  project             = var.project
  security_group_name = "public-security-group"
  extra_tags          = local.common_tags

  security_group_rules = [
    {
      type        = "ingress"
      to_port     = 443
      protocol    = "tcp"
      from_port   = 443
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      to_port     = 80
      protocol    = "tcp"
      from_port   = 80
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      to_port     = 22
      protocol    = "tcp"
      from_port   = 22
      cidr_blocks = ["123.231.106.0/32"]
    },
    {
      type        = "ingress"
      to_port     = 0
      protocol    = "-1"
      from_port   = 65535
      cidr_blocks = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
    }
  ]
}

module "eks_private_security_group" {
  source              = "../../modules/security_group"
  aws_vpc_id          = module.vpc.vpc_id
  description         = "private security group"
  environment         = var.environment
  project             = var.project
  security_group_name = "private-security-group"
  extra_tags          = local.common_tags

  security_group_rules = [
    {
      type        = "ingress"
      to_port     = 443
      protocol    = "tcp"
      from_port   = 443
      cidr_blocks = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
    },
    {
      type        = "ingress"
      to_port     = 80
      protocol    = "tcp"
      from_port   = 80
      cidr_blocks = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
    },
    {
      type        = "ingress"
      to_port     = 22
      protocol    = "tcp"
      from_port   = 22
      cidr_blocks = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
    },
    {
      type        = "ingress"
      to_port     = 0
      protocol    = "-1"
      from_port   = 65535
      cidr_blocks = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
    }
  ]
}


module "bastion_host" {
  source                 = "../../modules/ec2"
  instance_type          = var.bastion_vm_type
  launch_template        = "bastion_host"
  public_subnet_ids      = module.vpc.public_subnets
  image_id               = var.bastion_image_id
  vpc_security_group_ids = [module.eks_public_security_group.security_group_id]
  key_name               = var.bastion_key_pair
  ec2_desire_size        = var.ec2_desire_size
  ec2_max_size           = var.ec2_max_size
  ec2_min_size           = var.ec2_min_size
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = var.eks_cluster_name
  environment        = var.environment
  project            = var.project
  private_subnet_ids = module.vpc.private_subnets
  security_group_ids = [module.eks_private_security_group.security_group_id]
  eks_desired_size   = var.eks_desired_size
  eks_max_size       = var.eks_max_size
  eks_min_size       = var.eks_min_size
  node_groups_configs = {
    "nodegroup" = {
      instance_type = "t3.small"
      key_name      = "eks_ng_key_pair"
      image_id      = "ami-0319c884da18af515"
      disk_size     = 30
    }
  }
}