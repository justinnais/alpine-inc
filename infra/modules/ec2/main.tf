resource "aws_key_pair" "deployer" {
  key_name   = "rmit-assignment-2-key"
  public_key = file("/tmp/keys/ec2-key.pub")
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  key_name                    = aws_key_pair.deployer.key_name
  instance_type               = var.instance_type
  subnet_id                   = var.private_az1_subnet_id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  tags = {
    "Name" = "web"
  }
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.amazon_linux.id
  key_name                    = aws_key_pair.deployer.key_name
  instance_type               = var.instance_type
  subnet_id                   = var.data_az1_subnet_id
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  associate_public_ip_address = true

  tags = {
    "Name" = "db"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Web SG"
  description = "Allow ingress on app port and SSH on port 22"
  vpc_id      = var.vpc_id

  ingress {
    description = "ingress from app"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web SG"
  }

}

resource "aws_security_group" "db_sg" {
  name        = "Database SG"
  description = "Allow ingress on database port and SSH on port 22"
  vpc_id      = var.vpc_id

  ingress {
    description = "ingress from database"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database SG"
  }

}
