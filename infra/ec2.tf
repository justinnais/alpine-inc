resource "aws_key_pair" "deployer" {
  key_name   = "rmit-assignment-2-key"
  public_key = file("/tmp/keys/ec2-key.pub")
}

resource "aws_instance" "web" {
  ami               = var.aws-linux-2-ami
  instance_type     = "t2.micro"
  availability_zone = "private-az1"
}

resource "aws_instance" "db" {
  ami               = var.aws-linux-2-ami
  instance_type     = "t2.micro"
  availability_zone = "data_az1"
}