variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "enable_private_subnet" {
  description = "Enable creating private subnet with NAT gateway"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "A map of public subnets inside the VPC with respective availability zone"
  type        = map(string)
  default     = {}
}

variable "private_subnets" {
  description = "A map of private subnets inside the VPC with respective availability zone"
  type        = map(string)
  default     = {}
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common list of tags"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "List of tags to use in public subnet"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "List of tags to use in private subnet"
  type        = map(string)
  default     = {}
}