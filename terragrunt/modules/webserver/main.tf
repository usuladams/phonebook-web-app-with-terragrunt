data "aws_ami" "latest-amazon-linux2023-image" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# resource "aws_instance" "myapp-server" {
#   #ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
#   ami           = data.aws_ami.latest-amazon-linux2023-image.id
#   instance_type = var.ec2_type
#   key_name      = var.keypair  # write your pem file without .pem extension
#   vpc_security_group_ids = [ var.myapp-sg-id ]
#   subnet_id     = var.subnet_id
#   user_data = file("userdata.sh")
#   associate_public_ip_address = true

#   tags = {
#     Name = "${var.env_prefix}-ec2-server"
#   }
# }


resource "aws_lb_target_group" "alb-target" {
  name        = "${var.env_prefix}-tf-myapp-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      healthy_threshold = 2
      unhealthy_threshold = 3
      timeout = 10
  }

}


resource "aws_launch_template" "myapp-lt" {
  name = "${var.env_prefix}-myapp-lt"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  }

  image_id = data.aws_ami.latest-amazon-linux2023-image.id

  instance_type = var.ec2_type

  key_name = var.keypair

  vpc_security_group_ids = [ var.myapp-sg-id ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env_prefix}-phonebook-app-server"
    }    
  }

  #user_data = filebase64("${path.module}/userdata.sh")
  user_data = base64encode(templatefile("userdata.sh", {dbendpoint = var.dbendpoint}))
}


resource "aws_lb" "myapp-alb" {
  name               = "${var.env_prefix}-phonebook-lb-tf"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [ var.alb-sg-id ]
  subnets            = jsondecode(var.public_subnet_ids)

  tags = {
    Name = "${var.env_prefix}-phonebook-lb"
  }
}


resource "aws_lb_listener" "myapp-listener" {
  load_balancer_arn = aws_lb.myapp-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
}


resource "aws_autoscaling_group" "myapp-ASG" {
  name               = "${var.env_prefix}-myapp-phonebook-asg"
  #availability_zones = [ var.avail_zone ]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.myapp-lt.id
    version = aws_launch_template.myapp-lt.latest_version
  }

  target_group_arns = [ aws_lb_target_group.alb-target.arn ]
  health_check_type = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier = jsondecode(var.private_subnet_ids)
}


resource "aws_iam_role" "ec2_role" {
  name = "${var.env_prefix}-SSM-phonebook-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.env_prefix}-SSM-phonebook-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "${var.env_prefix}-ec2-ssm-phonebook-instance-profile"
  role = aws_iam_role.ec2_role.name
}
