resource "aws_security_group" "this" {
  name        = join("-", [var.environment, var.project, var.security_group_name, "sg"])
  description = var.description
  vpc_id      = var.aws_vpc_id

  tags = merge({
    Name = join("-", [var.environment, var.project, var.security_group_name])
  }, var.extra_tags)
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  to_port           = 0
  protocol          = -1
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id

  depends_on = [aws_security_group.this]
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.security_group_rules) > 0 ? length(var.security_group_rules) : 0

  type              = lookup(var.security_group_rules[count.index], "type")
  to_port           = lookup(var.security_group_rules[count.index], "to_port")
  protocol          = lookup(var.security_group_rules[count.index], "protocol")
  from_port         = lookup(var.security_group_rules[count.index], "from_port")
  cidr_blocks       = lookup(var.security_group_rules[count.index], "cidr_blocks", null)
  security_group_id = aws_security_group.this.id

  depends_on = [aws_security_group.this]
}