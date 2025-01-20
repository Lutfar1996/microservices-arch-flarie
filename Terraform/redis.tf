
# Security group for ElastiCache
resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-redis-sg"
  description = "Security group for Redis access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Redis Access"
    from_port   = 6379
    to_port     = 6379
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

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "default" {
  name       = "elasticache-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "elasticache-subnet-group"
  }
}

# ElastiCache Redis Replication Group
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "my-redis-cluster"
  description          = "Highly available Redis cluster"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = "cache.t3.micro"
  automatic_failover_enabled = true
  multi_az_enabled     = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.elasticache_sg.id]

  # Specify at least 2 cache clusters for automatic failover
  num_cache_clusters = 2

  lifecycle {
    ignore_changes = [snapshot_retention_limit]
  }

  tags = {
    Name = "my-redis-cluster"
  }
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  value = 6379 # Redis uses port 6379 by default
}
