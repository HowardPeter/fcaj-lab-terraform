resource "aws_lb_target_group" "this" {
  name             = "fcaj-asg"
  port             = 5000
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = aws_vpc.main.id
  target_type      = "instance"
  ip_address_type  = "ipv4"

  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = "5000"
    path     = "/"

    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb" "this" {
  name               = "fcaj-alb"
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.ec2.id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}