resource "aws_lb" "notes_app" {
  name               = "notes-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id, aws_subnet.public_az3.id]
}

resource "aws_lb_target_group" "notes_app" {
  name     = "notes-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.notes_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notes_app.arn
  }

}