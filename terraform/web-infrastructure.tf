//VPC
resource "aws_vpc" "infodsm-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    service = "infodsm"
    Name = "infodsm-vpc"
  }
}

//PublicSubnetA
resource "aws_subnet" "infodsm-subnet-publicA" {
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-2a"
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-subnet-publicA"
  }
}

//PublicSubnetB
resource "aws_subnet" "infodsm-subnet-publicB" {
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-2b"
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-subnet-publicB"
  }
}

//PrivateSubnetA
resource "aws_subnet" "infodsm-subnet-privateA" {
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-2a"
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-subnet-privateA"
  }
}

//PrivateSubnetB
resource "aws_subnet" "infodsm-subnet-privateB" {
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-2b"
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-subnet-privateB"
  }
}

//InternetGateway
resource "aws_internet_gateway" "infodsm-igw" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-igw"
  }
}

//EIP
resource "aws_eip" "infodsm-eip" {
  vpc = true
}

resource "aws_eip_association" "infodsm-eip-association" {
  allocation_id = aws_eip.infodsm-eip.id
  instance_id = aws_instance.infodsm-ec2-prod.id
}

//NAT Gateway
resource "aws_nat_gateway" "infodsm-ngw" {
  allocation_id = aws_eip.infodsm-eip.id
  subnet_id = aws_subnet.infodsm-subnet-publicA.id

  tags = {
    service = "infodsm"
    Name = "infodsm-ngw"
  }
}

//Public RouteTable
resource "aws_route_table" "infodsm-rt-public" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-rt-public"
  }
}

resource "aws_route_table_association" "infodsm-rt-public-association-1" {
  route_table_id = aws_route_table.infodsm-rt-public.id
  subnet_id = aws_subnet.infodsm-subnet-publicA.id
}

resource "aws_route_table_association" "infodsm-rt-public-association-2" {
  route_table_id = aws_route_table.infodsm-rt-public.id
  subnet_id = aws_subnet.infodsm-subnet-publicB.id
}

//Public RouteTable Routing
resource "aws_route" "infodsm-rt-public-route-1" {
  route_table_id = aws_route_table.infodsm-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.infodsm-igw.id
}

//PrivateA RouteTable
resource "aws_route_table" "infodsm-rt-privateA" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-rt-privateA"
  }
}

//PrivateA RouteTableAssociation
resource "aws_route_table_association" "infodsm-rt-privateA-association-1" {
  route_table_id = aws_route_table.infodsm-rt-privateA.id
  subnet_id = aws_subnet.infodsm-subnet-privateA.id
}

//PrivateA RouteTable Routing
resource "aws_route" "infodsm-rt-privateA-route-1" {
  route_table_id = aws_route_table.infodsm-rt-privateA.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.infodsm-ngw.id
}

//PrivateB RouteTable
resource "aws_route_table" "infodsm-rt-privateB" {
  vpc_id = aws_vpc.infodsm-vpc.id

  tags = {
    service = "infodsm"
    Name = "infodsm-rt-privateB"
  }
}

//PrivateB RouteTableAssociation
resource "aws_route_table_association" "infodsm-rt-privateB-association-1" {
  route_table_id = aws_route_table.infodsm-rt-privateB.id
  subnet_id = aws_subnet.infodsm-subnet-privateB.id
}

//PrivateB RouteTable Routing
resource "aws_route" "infodsm-rt-privateB-route-1" {
  route_table_id = aws_route_table.infodsm-rt-privateB.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.infodsm-ngw.id
}



//KeyPair for EC2
resource "aws_key_pair" "infodsm-key" {
  public_key = file("~/.ssh/id_rsa.pub")
  key_name = "infodsm-key"

  tags = {
    service = "infodsm"
  }
}

//SecurityGroups
resource "aws_security_group" "infodsm-sg-ssh" {
  description = "Allow 22port for ssh"
  vpc_id = aws_vpc.infodsm-vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    service = "infodsm"
    Name = "infodsm-sg-ssh"
  }
}

resource "aws_security_group" "infodsm-sg-cloudflare" {
  description = "Allow 443port for Cloudflare"
  vpc_id = aws_vpc.infodsm-vpc.id
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "108.162.192.0/18",
      "131.0.72.0/22",
      "141.101.64.0/18",
      "162.158.0.0/15",
      "172.64.0.0/13",
      "173.245.48.0/20",
      "188.114.96.0/20",
      "190.93.240.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17"
    ]
  }
  tags = {
    service = "infodsm"
    Name = "infodsm-sg-cloudflare"
  }
}



//BastionInstance
resource "aws_instance" "infodsm-ec2-bastion" {
  ami = "ami-09cd5dd529c3c1f40"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.infodsm-subnet-publicB.id
  security_groups = [aws_security_group.infodsm-sg-ssh.id]
  key_name = "infodsm-key"

  tags = {
    service = "infodsm"
    Name = "infodsm-ec2-bastion"
  }
}

//ServiceInstance
resource "aws_instance" "infodsm-ec2-prod" {
  ami = "ami-09cd5dd529c3c1f40"
  instance_type = "t3.medium"
  subnet_id = aws_subnet.infodsm-subnet-publicA.id
  security_groups = [
    aws_security_group.infodsm-sg-ssh.id,
    aws_security_group.infodsm-sg-cloudflare.id
  ]
  key_name = "infodsm-key"

  tags = {
    service = "infodsm"
    Name = "infodsm-ec2-prod"
  }
}
