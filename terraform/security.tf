# 1. SECURITY GROUP CHO APPLICATION LOAD BALANCER (ALB)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Cho phép traffic web (HTTP/HTTPS) từ Internet vào ALB."
  vpc_id      = aws_vpc.main.id 

  # --- Luồng vào (Ingress) ---
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from Internet"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from Internet"
  }

  # --- Luồng ra (Egress) ---
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] 
    description = "Allow ALB to talk to internal resources (e.g., Web Tier)"
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# 2. SECURITY GROUP CHO WEB TIER (EC2 INSTANCES)
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-ec2-sg"
  description = "Cho phép traffic từ ALB và SSH từ IP của bạn."
  vpc_id      = aws_vpc.main.id

  # --- Luồng vào (Ingress) ---
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] 
    description     = "Allow traffic from ALB"
  }
  
  # --- Luồng ra (Egress) ---
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-ec2-sg"
  }
}

# 3. SECURITY GROUP CHO DATABASE TIER (RDS INSTANCE)
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-rds-sg"
  description = "CHỈ cho phép traffic từ Web Tier (EC2) vào CSDL."
  vpc_id      = aws_vpc.main.id

  # --- Luồng vào (Ingress) ---
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id] 
    description     = "Allow traffic from Web EC2 instances"
  }

  # --- Luồng ra (Egress) ---
  tags = {
    Name = "${var.environment}-db-rds-sg"
  }
}

