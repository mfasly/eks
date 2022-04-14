variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "description" {
  type = string
}

variable "aws_vpc_id" {
  type = string
}

variable "security_group_rules" {
  description = <<EOF
    list(object({
      type        = string
      to_port     = number
      protocol    = string
      from_port   = number
      self        = optional(bool)
      description = string
      source_security_group_id = optional(string)
    }))
  EOF
}

variable "security_group_rules_cidr" {
  type = list(object({
    type        = string
    to_port     = number
    protocol    = string
    from_port   = number
    cidr_blocks = list(string)
    description = string
  }))
  description = <<EOF
    list(object({
      type        = string
      to_port     = number
      protocol    = string
      from_port   = number
      cidr_blocks = list(string)
      description = string
    }))
  EOF
  default     = []
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}