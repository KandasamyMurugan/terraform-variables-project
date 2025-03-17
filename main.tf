resource "aws_vpc" "vari_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_tag
  }
}

resource "aws_internet_gateway" "vari-igw" {
  vpc_id = aws_vpc.vari_vpc.id
  tags = {
    Name = var.vari_igw
  }
}

resource "aws_subnet" "vari_subnet-1a" {
  vpc_id            = aws_vpc.vari_vpc.id
  cidr_block        = var.sub1_cidr_block
  availability_zone = var.sub1_az

  tags = {
    Name = "Vari_Subnet2"
  }
}

resource "aws_subnet" "vari_subnet-1b" {
  vpc_id            = aws_vpc.vari_vpc.id
  cidr_block        = var.sub2_cidr_block
  availability_zone = var.sub2_az

  tags = {
    Name = "Vari_Subnet2"
  }
}

resource "aws_subnet" "vari_subnet-1c" {
  vpc_id            = aws_vpc.vari_vpc.id
  cidr_block        = var.sub3_cidr_block
  availability_zone = var.sub3_az

  tags = {
    Name = "Vari_Subnet1"
  }
}

resource "aws_route_table" "vari_rt_public" {
  vpc_id = aws_vpc.vari_vpc.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.vari-igw.id
  }
  tags = {
    Name = var.rt_tag
  }
}

resource "aws_route_table_association" "vari_rt_association-1" {
  subnet_id      = aws_subnet.vari_subnet-1a.id
  route_table_id = aws_route_table.vari_rt_public.id
}

resource "aws_route_table_association" "variable_rt_association-2" {
  subnet_id      = aws_subnet.vari_subnet-1b.id
  route_table_id = aws_route_table.vari_rt_public.id
}

resource "aws_route_table_association" "variable_rt_association-3" {
  subnet_id      = aws_subnet.vari_subnet-1c.id
  route_table_id = aws_route_table.vari_rt_public.id
}

resource "aws_security_group" "vari_sg" {
  name   = "web"
  vpc_id = aws_vpc.vari_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_instance" "vari_instance" {
  ami                         = var.ami
  instance_type               = var.ec2_type
  subnet_id                   = aws_subnet.vari_subnet-1b.id
  vpc_security_group_ids      = [aws_security_group.vari_sg.id]
  associate_public_ip_address = true


  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y nginx
    echo "<h1>${var.env}-Server-1</h1>" | sudo tee /var/www/html/index.html
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF


  tags = {
    Name = var.ec2_tag
  }

  lifecycle {
    create_before_destroy = true
  }
}
