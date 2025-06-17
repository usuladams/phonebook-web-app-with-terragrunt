output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux2023-image
}


output "alb-dnsname" {
  value = aws_lb.myapp-alb
}