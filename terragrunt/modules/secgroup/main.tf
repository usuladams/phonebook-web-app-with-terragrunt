resource "aws_security_group" "alb-sg" {
  name = "alb-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env_prefix}-alb-sg"
  }  
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    security_groups = [ aws_security_group.alb-sg.id ]
  }

  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env_prefix}-ec2-sg"
  }  
}

resource "aws_security_group" "rds-sg" {
  name = "rds-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    security_groups = [ aws_security_group.myapp-sg.id ]
  }
  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env_prefix}-db-sg"
  }  
}

resource "aws_security_group" "nat-sg" {
  name = "nat-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
      from_port = 443
      protocol = "tcp"
      to_port = 443
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env_prefix}-nat-sg"
  }  
}