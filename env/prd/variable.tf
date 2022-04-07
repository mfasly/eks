variable "region" {
  description = "AWS region which resource are creating"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnets inside the VPC with respective availability zone"
  type        = map(string)
}

variable "private_subnets" {
  description = "A map of private subnets inside the VPC with respective availability zone"
  type        = map(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "bastion_vm_type" {
  description = "VM type of the Bastion Host"
  type        = string
}

variable "bastion_image_id" {
  description = "AMI image ID of bastion host"
  type        = string
}

variable "bastion_key_pair" {
  description = "Bastion Host authentication key pair"
  type        = string
}

variable "ec2_max_size" {
  description = "No of max nodes asg"
  type        = string
}

variable "ec2_min_size" {
  description = "No of min nodes asg"
  type        = string
}

variable "ec2_desire_size" {
  description = "No of desired nodes asg"
  type        = string
}

variable "eks_desired_size" {
  description = "Desired no of nodes in EKS cluster"
  type        = string
  default     = "1"
}

variable "eks_max_size" {
  description = "Desired no of nodes in EKS cluster"
  type        = string
  default     = "5"
}

variable "eks_min_size" {
  description = "Desired no of nodes in EKS cluster"
  type        = string
  default     = "1"
}
