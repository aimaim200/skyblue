/*resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ec2_key"
  public_key = tls_private_key.test.public_key_openssh
}*/


data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet" "public_subnet" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["DMZ_b"]
  }

  availability_zone = "eu-west-2b"
}

resource "aws_instance" "ec2_host" {
  ami                         = "ami-0ffd774e02309201f"
  instance_type               = "t2.micro"
  iam_instance_profile        = "ec2-profile"
  subnet_id                   = data.aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  #key_name                    = aws_key_pair.generated_key.key_name
  key_name = "skyblue"
  tags = {
    Name = "nginx_ec2"
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "nginx_sg"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", "10.0.0.0/8"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 19999
    to_port     = 19999
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