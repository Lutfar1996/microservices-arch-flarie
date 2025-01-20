# Create a VPC (for isolation)
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create two subnets for the ECS Service (public subnets)
resource "aws_subnet" "ecs_subnet_a" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ecs_subnet_b" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Security group for ECS Service
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow traffic to ECS tasks"
  vpc_id      = aws_vpc.ecs_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define ECS Task Definition for Fargate
resource "aws_ecs_task_definition" "flarie_task" {
  family                   = "flarie-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "flarie-container"
    image     = "public.ecr.aws/k7m2z4k7/flarie:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
  }])
}

# Create ECS Cluster for Fargate
resource "aws_ecs_cluster" "flarie_cluster" {
  name = "flarie-cluster"
}

# Create ECS Service for Fargate (No ALB)
resource "aws_ecs_service" "flarie_service" {
  name            = "flarie-service"
  cluster         = aws_ecs_cluster.flarie_cluster.id
  task_definition = aws_ecs_task_definition.flarie_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.ecs_subnet_a.id, aws_subnet.ecs_subnet_b.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
