variable "launch_template" {
  description = "The name of the launch template"
  type        = string
}

variable "instance_type" {
  description = "Type of the Instance"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
  default     = []
}

variable "image_id" {
  description = "Type of the Instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Type of the Instance"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the SSH key"
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

