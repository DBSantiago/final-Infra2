provider "aws" {
  region = "us-east-1"
  alias = "amazon"
  access_key = "AKIAWB4P7DBD7ALLI3RX"
  secret_key = "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"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_public_key.pk.public_key_openssh       
  
  provisioner "local-exec" {
    command = "echo '${tls_public_key.pk.public_key_pem}' > ./myKey.pem"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
    id = "vpc-0e5bab5b74e4edddb"
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_security_group" "sg" {
  name = "Security_Group_DH"
  description = "Grupo de seguridad"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    }

    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    }

    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = true
    }
  }

  tags = {
      Name = "Security_Group_DH"
  }
}

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  subnet_id = tolist(data.aws_subnet_ids.subnets.ids)[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = "myKey"
  tags = {
    Name = "Frontend"
  }
}
