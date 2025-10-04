provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.public_subnet_az

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_az

  tags = {
    Name = "PrivateSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route.id
}

# Security Group for Public Subnet
resource "aws_security_group" "public_subnet_sg" {
  name        = "security-group-for-public-subnet"
  description = "Security group for public subnet"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add additional inbound rules as needed for resources in the public subnet
  # For example, if you're hosting a web server, you might need to allow HTTP (port 80) and HTTPS (port 443) traffic

  tags = {
    Name = "PublicSubnetSG"
    env  = "testing"
    # Add more tags as needed
  }
}

# Security Group for Private Subnet
resource "aws_security_group" "private_subnet_sg" {
  name        = "security-group-for-private-subnet"
  description = "Security group for private subnet"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add additional inbound rules as needed for resources in the private subnet
  # For example, if you have a database server in the private subnet, you might need to allow database port (e.g., 3306 for MySQL) traffic from specific IP ranges or security groups

  tags = {
    Name = "PrivateSubnetSG"
    env  = "testing"
    # Add more tags as needed
  }
}

resource "tls_private_key" "ec2_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-access"
  
  # Generate a new key pair
  public_key = tls_private_key.ec2_key_pair.public_key_openssh
}

resource "aws_instance" "public_instance" {
  ami                    = var.public_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_subnet_sg.id]

  tags = {
    Name = "PublicInstance"
    # Add additional tags as needed
  }

  # key_name               = aws_key_pair.ec2_key_pair.key_name
}

resource "aws_instance" "private_instance" {
  ami                    = var.private_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_subnet_sg.id]

  tags = {
    Name = "PrivateInstance"
    # Add additional tags as needed
  }

  # key_name               = aws_key_pair.ec2_key_pair.key_name
}