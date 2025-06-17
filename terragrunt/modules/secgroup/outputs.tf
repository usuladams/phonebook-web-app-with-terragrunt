output "alb-sg" {
  value = aws_security_group.alb-sg
}

output "myapp-sg" {
  value = aws_security_group.myapp-sg
}

output "rds-sg" {
  value = aws_security_group.rds-sg
}

output "nat-sg" {
  value = aws_security_group.nat-sg
}