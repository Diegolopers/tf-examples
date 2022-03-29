resource "aws_launch_configuration" "this" {
  name          = "lc_web_${var.envir}"
  image_id      = var.web_image_id
  instance_type = var.web_instance_type
  security_groups = var.security_groups
  
}

resource "aws_autoscaling_group" "this" {
  name                 = "asg-web-${var.envir}"
  launch_configuration = aws_launch_configuration.this.name
  desired_capacity   = var.web_desired_capacity
  max_size           = var.web_max_size
  min_size           = var.web_min_size
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.this.arn]
}

resource "aws_lb" "this" {
  name               = "alb-web-${var.envir}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
resource "aws_lb_target_group" "this" {
  name     = "tg-web-${var.envir}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0ddc9800db2021c2b"
}