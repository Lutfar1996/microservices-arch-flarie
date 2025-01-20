# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow MySQL access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL Access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with specific IP ranges for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL instance
resource "aws_db_instance" "mysql" {
  identifier              = "my-mysql-db"
  engine                  = "mysql"
  engine_version          = "8.0" # Adjust version as needed
  instance_class          = "db.t3.micro" # Choose instance type based on requirements
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  username                = "admin"
  password                = "password123" # Use a secure password
  db_name                 = "flarie" # Specify the database name
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  multi_az                = true
  publicly_accessible     = false
}

# Create DB subnet group
resource "aws_db_subnet_group" "default" {
  name       = "default-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "default-db-subnet-group"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}
