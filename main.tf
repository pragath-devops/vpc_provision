#####provider , region , version & profile details #####
provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.88"
    }
  }
}

#####CReating VPC resource######

resource "aws_vpc" "devvpcname" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name        = "dev-vpc"
    Description = "DEV env VPC for DEV resources"
    Team        = "DevOps"
  }
}

######Create IGW  ######
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.devvpcname.id
  tags = {
    Name = "dev-vpc-internet-gateway"
  }
}

######Attach IGW to VPC####
#resource "aws_internet_gateway_attachment" "igw-attachment" {
#  internet_gateway_id = aws_internet_gateway.dev-igw.id
#  vpc_id              = aws_vpc.devvpcname.id
#}


###public subnets provision####

resource "aws_subnet" "pub-subnet-1a" {
  vpc_id                  = aws_vpc.devvpcname.id
  cidr_block              = "10.10.0.0/22"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "dev-vpc-public-subnet-1a"
  }
}


resource "aws_subnet" "pub-subnet-1b" {
  vpc_id                  = aws_vpc.devvpcname.id
  cidr_block              = "10.10.4.0/22"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "dev-vpc-public-subnet-1b"
  }
}


resource "aws_subnet" "pub-subnet-1c" {
  vpc_id                  = aws_vpc.devvpcname.id
  cidr_block              = "10.10.8.0/22"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "dev-vpc-public-subnet-1c"
  }
}


###private subnets provision####

resource "aws_subnet" "pri-subnet-1a" {
  vpc_id            = aws_vpc.devvpcname.id
  cidr_block        = "10.10.16.0/20"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "dev-vpc-private-subnet-1a"
  }
}


resource "aws_subnet" "pri-subnet-1b" {
  vpc_id            = aws_vpc.devvpcname.id
  cidr_block        = "10.10.32.0/20"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "dev-vpc-private-subnet-1b"
  }
}


resource "aws_subnet" "pri-subnet-1c" {
  vpc_id            = aws_vpc.devvpcname.id
  cidr_block        = "10.10.48.0/20"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "dev-vpc-private-subnet-1c"
  }
}

######Create public route table#######
resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.devvpcname.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }
  tags = {
    Name = "dev-vpc-public-route-table"
  }
}

########Create private route table###
resource "aws_route_table" "pri-route-table" {
  vpc_id = aws_vpc.devvpcname.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev-vpc-nat.id
  }
  tags = {
    Name = "dev-vpc-private-route-table"
  }
}

#####Create EIP ###
resource "aws_eip" "dev-vpc-eip" {
  domain = "vpc"
  tags = {
    Name = "dev-vpc-elastic-ip"
  }
}

####Create NAT Gateway####
resource "aws_nat_gateway" "dev-vpc-nat" {
  allocation_id = aws_eip.dev-vpc-eip.id
  subnet_id     = aws_subnet.pub-subnet-1a.id
  tags = {
    Name = "dev-vpc-nat-gateway"
  }
}

####Associate public subnet 1a to public route table###
resource "aws_route_table_association" "pub-subnet-1a-to-route-table-association" {
  subnet_id      = aws_subnet.pub-subnet-1a.id
  route_table_id = aws_route_table.pub-route-table.id
}

####Associate public subnet 1b to public route table###
resource "aws_route_table_association" "pub-subnet-1b-to-route-table-association" {
  subnet_id      = aws_subnet.pub-subnet-1b.id
  route_table_id = aws_route_table.pub-route-table.id
}

####Associate public subnet 1c to public route table###
resource "aws_route_table_association" "pub-subnet-1c-to-route-table-association" {
  subnet_id      = aws_subnet.pub-subnet-1c.id
  route_table_id = aws_route_table.pub-route-table.id
}


####Associate private subnet 1a to private route table###
resource "aws_route_table_association" "pri-subnet-1a-to-route-table-association" {
  subnet_id      = aws_subnet.pri-subnet-1a.id
  route_table_id = aws_route_table.pri-route-table.id
}

####Associate private subnet 1b to private route table###
resource "aws_route_table_association" "pri-subnet-1b-to-route-table-association" {
  subnet_id      = aws_subnet.pri-subnet-1b.id
  route_table_id = aws_route_table.pri-route-table.id
}

####Associate private subnet 1c to private route table###
resource "aws_route_table_association" "pri-subnet-1c-to-route-table-association" {
  subnet_id      = aws_subnet.pri-subnet-1c.id
  route_table_id = aws_route_table.pri-route-table.id
}

###Create public NACL###
resource "aws_network_acl" "pub-nacl" {
  vpc_id = aws_vpc.devvpcname.id
  tags = {
    Name = "dev-vpc-public-nacl"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}



###Create private NACL###
resource "aws_network_acl" "pri-nacl" {
  vpc_id = aws_vpc.devvpcname.id
  tags = {
    Name = "dev-vpc-private-nacl"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


####Associate public subnet 1a to public NACL###
resource "aws_network_acl_association" "pub-sub-1a-to-nacl-association" {
  network_acl_id = aws_network_acl.pub-nacl.id
  subnet_id      = aws_subnet.pub-subnet-1a.id
}

####Associate public subnet 1b to public NACL###
resource "aws_network_acl_association" "pub-sub-1b-to-nacl-association" {
  network_acl_id = aws_network_acl.pub-nacl.id
  subnet_id      = aws_subnet.pub-subnet-1b.id
}

####Associate public subnet 1c to public NACL###
resource "aws_network_acl_association" "pub-sub-1c-to-nacl-association" {
  network_acl_id = aws_network_acl.pub-nacl.id
  subnet_id      = aws_subnet.pub-subnet-1c.id
}




####Associate private subnet 1a to private NACL###
resource "aws_network_acl_association" "pri-sub-1a-to-nacl-association" {
  network_acl_id = aws_network_acl.pri-nacl.id
  subnet_id      = aws_subnet.pri-subnet-1a.id
}

####Associate private subnet 1b to private NACL###
resource "aws_network_acl_association" "pri-sub-1b-to-nacl-association" {
  network_acl_id = aws_network_acl.pri-nacl.id
  subnet_id      = aws_subnet.pri-subnet-1b.id
}

####Associate private subnet 1c to private NACL###
resource "aws_network_acl_association" "pri-sub-1c-to-nacl-association" {
  network_acl_id = aws_network_acl.pri-nacl.id
  subnet_id      = aws_subnet.pri-subnet-1c.id
}


######Create security Group for public EC2 servers###
resource "aws_security_group" "sg-for-ec2" {
  vpc_id      = aws_vpc.devvpcname.id
  description = "This SG for public EC2 servers access"
  tags = {
    Name = "ec2-public-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


######Create security Group for public ALB ###
resource "aws_security_group" "alb-pub-sg" {
  vpc_id      = aws_vpc.devvpcname.id
  name        = "alb-public-security-group"
  description = "This SG for public ALB access"
  tags = {
    Name = "alb-public-sg"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


#######Provision public EC2 server in DEV VPC###
resource "aws_instance" "dev-server" {
  ami                    = "ami-00bb6a80f01f03502"
  instance_type          = "t3a.medium"
  key_name               = "test-delete"
  subnet_id              = aws_subnet.pub-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.sg-for-ec2.id]
  user_data              = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install nginx -y
        sudo systemctl enable nginx.service -y
  EOF
  tags = {
    Name = "dev-app-server1"
  }
}
