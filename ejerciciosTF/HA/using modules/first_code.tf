variable "web_image_id"{
type = string
}
variable "web_instance_type"{
type = string
}
variable "web_desired_capacity"{
type = number
}
variable "web_max_size"{
type = number
}
variable "web_min_size"{
type = number
}
variable "subnets"{
type = list(string)
}
provider "aws"{
    profile = "default"
    region = "us-east-1"
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
module "web_app" {
  source = "./modules/web_app"

  web_image_id = var.web_image_id
  web_instance_type = var.web_instance_type
  web_desired_capacity = var.web_desired_capacity
  web_max_size = var.web_max_size
  web_min_size = var.web_min_size
  subnets = var.subnets
  security_groups = [aws_security_group.sg_web_prod.id]
  envir = "prod"
}