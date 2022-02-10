provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name           = "playlisten"
  cidr           = "10.0.0.0/16"
  azs            = data.aws_availability_zones.available.names
  public_subnets = ["10.0.101.0/24"]

  database_subnets             = ["10.0.13.0/24", "10.0.14.0/24"]
  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "standalone_playlisten_instance" {
  name   = "standalone_playlisten_instance"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "allow HTTP connection, would redirect to HTTPS in nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTPS connection"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow ssh connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow mysql connection"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "standalone_playlisten_instance"
  }
}


resource "aws_network_interface" "playlisten_network_interface" {
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.standalone_playlisten_instance.id]

  tags = {
    Name = "primary_network_interface"
  }
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
resource "aws_instance" "playlisten" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.playlisten_network_interface.id
    device_index         = 0
  }
  key_name = var.key_name
  tags = {
    Name = "standalone_playlisten_instance"
  }
}

data "aws_eip" "by_public_ip" {
  public_ip = var.registered_domain_dns_addr
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.playlisten.id
  allocation_id = data.aws_eip.by_public_ip.id
}
