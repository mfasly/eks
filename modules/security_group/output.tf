output "security_group_id" {
  value      = aws_security_group.this.id
  depends_on = [aws_security_group.this]
}

output "security_group_arn" {
  value      = aws_security_group.this.arn
  depends_on = [aws_security_group.this]
}