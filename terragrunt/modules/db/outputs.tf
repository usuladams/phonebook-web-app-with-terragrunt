output "db-endpoint" {
  value = aws_db_instance.db-server
  sensitive = true
}