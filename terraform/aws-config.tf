resource "aws_vpc" "infodsm-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "infodsm-vpc"
  }
}

//InternetGateway
resource "aws_internet_gateway" "infodsm-igw" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    Name = "infodsm-igw"
  }
}

resource "aws_route_table" "infodsm-rt-public" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    Name = "infodsm-rt-public"
  }
}

resource "aws_route_table_association" "infodsm-rt-public-association-1" {
  route_table_id = aws_route_table.infodsm-rt-public.id
  subnet_id      = aws_subnet.infodsm-subnet-public.id
}

//Public RouteTable Routing
resource "aws_route" "infodsm-rt-public-route-1" {
  route_table_id         = aws_route_table.infodsm-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.infodsm-igw.id
}

//PublicSubnet
resource "aws_subnet" "infodsm-subnet-public" {
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  vpc_id                  = aws_vpc.infodsm-vpc.id

  tags = {
    Name = "infodsm-subnet-public"
  }

}

//SecurityGroup
resource "aws_security_group" "infodsm-sg-ssh" {
  description = "Allow 22port for ssh"
  vpc_id      = aws_vpc.infodsm-vpc.id
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
    Name = "infodsm-sg-ssh"
  }
}

resource "aws_security_group" "infodsm-sg-https" {
  description = "Allow 443port for ssh"
  vpc_id      = aws_vpc.infodsm-vpc.id


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
    Name = "infodsm-sg-https"
  }
}

resource "aws_key_pair" "local-key" {
  public_key = var.public_key
  key_name   = var.infodsm_key_name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["ubuntu"] //ubuntu
  }

}


resource "aws_instance" "infodsm-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.infodsm-subnet-public.id

  security_groups = [
    aws_security_group.infodsm-sg-ssh.id,
    aws_security_group.infodsm-sg-https.id
  ]
  key_name = var.infodsm_key_name

  tags = {
    Name = "infodsm-ec2"
  }

  user_data = <<EOF
  #!/bin/bash
  sudo apt update
  sudo apt install python3 -y
  sudo timedatectl set-timezone Asia/Seoul
  echo Done!
EOF

}
