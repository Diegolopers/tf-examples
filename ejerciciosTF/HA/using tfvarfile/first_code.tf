variable "region" {
    type = string
}
provider "aws"{
    profile = "default"
    region = var.region
}
resource "aws_security_group" "sg_web_prod" {
  name = "sg_web_prod"
  vpc_id = "vpc-0ddc9800db2021c2b"
  ingress  {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "sg para web server en asg"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  } 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_launch_configuration" "lc_web_prod" {
  name          = "lc_web_prod"
  image_id      = "ami-091f9c91e46695323"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.sg_web_prod.id]
  
}

resource "aws_autoscaling_group" "asg_web_prod" {
  name                 = "asg-web-prod"
  launch_configuration = aws_launch_configuration.lc_web_prod.name
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier = ["subnet-0d5e524fd447de33c","subnet-003b8451cb2404fea"]
  target_group_arns = [aws_lb_target_group.tg_web_prod.arn]
}

resource "aws_lb" "alb_web_prod" {
  name               = "alb-web-prod"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_web_prod.id]
  subnets            = ["subnet-0d5e524fd447de33c","subnet-003b8451cb2404fea"]
}

resource "aws_lb_listener" "listener_web_prod" {
  load_balancer_arn = aws_lb.alb_web_prod.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web_prod.arn
  }
}
resource "aws_lb_target_group" "tg_web_prod" {
  name     = "tg-web-prod"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0ddc9800db2021c2b"
}