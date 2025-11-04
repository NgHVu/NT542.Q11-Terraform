# 1. TẠO NHÓM SUBNET CHO CSDL
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private_db.*.id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# 2. TẠO CSDL RDS (RDS INSTANCE)
resource "aws_db_instance" "main" {
  allocated_storage = 20 
  instance_class    = var.db_instance_class
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  publicly_accessible = false 
  multi_az            = true  

  storage_type = "gp3"

  backup_retention_period = 7             
  backup_window           = "03:00-04:00" 
  maintenance_window      = "Sun:04:30-Sun:05:30" 

  performance_insights_enabled = true
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn 

  # --- Cấu hình CSDL (Database) ---
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password 

  # --- Cấu hình Mạng (Networking) ---
  vpc_security_group_ids = [aws_security_group.db.id] 
  db_subnet_group_name   = aws_db_subnet_group.main.name  

  # --- Cấu hình cho Sandbox ---
  skip_final_snapshot = true  
  deletion_protection = false
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

