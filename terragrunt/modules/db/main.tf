data "aws_ssm_parameter" "db_name" {
  name = "/baby/phonebook/dbname"
}

data "aws_ssm_parameter" "username" {
  name = "/baby/phonebook/username"
}

data "aws_ssm_parameter" "password" {
  name = "/baby/phonebook/password"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.env_prefix}-myapp-rds-subnet-group"
  subnet_ids = jsondecode(var.subnet_ids)

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "db-server" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  engine_version       = "8.0.40"
  instance_class       = var.rds_type
  identifier           = var.DBInstanceIdentifier

  db_name              = data.aws_ssm_parameter.db_name.value
  username             = data.aws_ssm_parameter.username.value
  password             = data.aws_ssm_parameter.password.value

  parameter_group_name      = "default.mysql8.0"
  vpc_security_group_ids    = [ var.rds-sg-id ]
  delete_automated_backups  = true
  publicly_accessible       = false
  backup_retention_period   = 7
  multi_az                  = false
  skip_final_snapshot       = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

}