resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "${var.prefix_name}-vpc"
  }
}

//InternetGateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix_name}-igw"
  }
}

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix_name}-rt-public"
  }
}

resource "aws_route_table_association" "rt-public-association-1" {
  route_table_id = aws_route_table.rt-public.id
  subnet_id      = aws_subnet.subnet-public.id
}

//Public RouteTable Routing
resource "aws_route" "rt-public-route-1" {
  route_table_id         = aws_route_table.rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

//PublicSubnet
resource "aws_subnet" "subnet-public" {
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix_name}-subnet-public"
  }

}

//SecurityGroup
resource "aws_security_group" "sg-ssh" {
  description = "Allow 22port for ssh"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix_name}-sg-ssh"
  }
}

resource "aws_security_group" "sg-https" {
  description = "Allow 443port for ssh"
  vpc_id      = aws_vpc.vpc.id


  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix_name}-sg-https"
  }
}

resource "aws_key_pair" "local-key" {
  public_key = var.public_key
  key_name   = var.key_name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet-public.id

  security_groups = [
    aws_security_group.sg-ssh.id,
    aws_security_group.sg-https.id
  ]
  key_name = var.key_name

  tags = {
    Name = "${var.prefix_name}-ec2"
  }

  user_data = <<EOF
  #!/bin/bash
  sudo apt update
  sudo apt install python3 -y
  sudo timedatectl set-timezone Asia/Seoul
  echo Done!
EOF

}
