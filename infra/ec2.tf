resource "aws_key_pair" "deployer" {
  key_name   = "rmit-assignment-2-key"
  public_key = file("/tmp/keys/ec2-key.pub")
}

resource "aws_instance" "web" {
  ami                    = var.aws-linux-2-ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    "Name" = "web"
  }
}

resource "aws_instance" "db" {
  ami                    = var.aws-linux-2-ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.data_subnet[0].id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    "Name" = "db"
  }
}
