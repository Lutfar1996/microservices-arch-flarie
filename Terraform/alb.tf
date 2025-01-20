# Create an Internet Gateway
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# Create ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow inbound HTTP traffic to ALB"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB
resource "aws_lb" "flarie_alb" {
  name               = "flarie-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.ecs_subnet_a.id, aws_subnet.ecs_subnet_b.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

# Create the ALB Target Group for Fargate
resource "aws_lb_target_group" "flarie_target_group" {
  name     = "flarie-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs_vpc.id

  target_type = "ip"  # Use IP target type for Fargate tasks

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create the ALB Listener
resource "aws_lb_listener" "flarie_listener" {
  load_balancer_arn = aws_lb.flarie_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flarie_target_group.arn
  }
}
