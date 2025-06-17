resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "myapp-public-subnets" {
  count = length(var.avail_zone)
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.public_subnet_cidr_block[count.index]
  availability_zone = var.avail_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_prefix}-public-subnet-${count.index + 1}"
    AZ   = var.avail_zone[count.index]
  }  
}

resource "aws_subnet" "myapp-private-subnets" {
  count = length(var.avail_zone)
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.private_subnet_cidr_block[count.index]
  availability_zone = var.avail_zone[count.index]

  tags = {
    Name = "${var.env_prefix}-private-subnet-${count.index + 1}"
    AZ   = var.avail_zone[count.index]
  }  
}


resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

resource "aws_route_table_association" "rtb-subnets" {
  count = length(aws_subnet.myapp-public-subnets)

  subnet_id      = aws_subnet.myapp-public-subnets[count.index].id
  route_table_id = aws_default_route_table.main-rtb.id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myapp-vpc.id
  depends_on = [aws_nat_gateway.nat_gw]
  
  # route {
  #   cidr_block           = "0.0.0.0/0"
  #   network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  # }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}

# resource "aws_route" "private_nat" {
#   route_table_id         = aws_route_table.private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   instance_id            = aws_instance.nat_instance.id
# }

resource "aws_route_table_association" "private-rtb-subnets" {
  count = length(aws_subnet.myapp-private-subnets)

  subnet_id      = aws_subnet.myapp-private-subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Create EIP
resource "aws_eip" "eip_nat_gw" {
  #instance = aws_instance.nat_instance.id
  domain = "vpc"
}

# Create Nat Instance

# resource "aws_instance" "nat_instance" {
#   ami           = var.nat_ami #"ami-0aa210fd2121a98b7"
#   instance_type = var.ec2_type
#   key_name      = var.keypair
#   vpc_security_group_ids = [ var.nat-sg-id ]
#   subnet_id     = aws_subnet.myapp-public-subnets[0].id
#   source_dest_check = false

#   tags = {
#     Name = "${var.env_prefix}-nat-instance"
# }
# }

# Create Nat GW

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat_gw.id
  subnet_id     = aws_subnet.myapp-public-subnets[0].id

  tags = {
    Name = "${var.env_prefix}-NAT-gw"
  }
  depends_on = [aws_internet_gateway.myapp-igw]
}

