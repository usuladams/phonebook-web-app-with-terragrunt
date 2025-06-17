output "public-subnet" {
  value = aws_subnet.myapp-public-subnets[*].id
}

output "private-subnet" {
  value = aws_subnet.myapp-private-subnets[*].id
}

output "vpc_id" {
  value = aws_vpc.myapp-vpc.id
}