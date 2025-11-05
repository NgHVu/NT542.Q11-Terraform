# BIẾN (VARIABLES) CHO PROVIDER VÀ AWS
variable "aws_region" {
  description = "Khu vực AWS (Region) để triển khai hạ tầng."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Môi trường triển khai (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Giá trị của 'environment' phải là 'dev', 'staging', hoặc 'prod'."
  }
}

variable "owner_email" {
  description = "Email của người sở hữu hoặc người tạo ra các tài nguyên này."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Giá trị 'owner_email' phải là một địa chỉ email hợp lệ."
  }
}

# BIẾN (VARIABLES) CHO HẠ TẦNG MẠNG (VPC)
variable "vpc_cidr" {
  description = "Dải IP CIDR chính cho VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.vpc_cidr))
    error_message = "Giá trị 'vpc_cidr' phải là một dải CIDR hợp lệ (ví dụ: 10.0.0.0/16)."
  }
}

variable "public_subnet_cidrs" {
  description = "Danh sách các dải IP CIDR cho public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24", # Đặt ở Availability Zone A
    "10.0.2.0/24"  # Đặt ở Availability Zone B
  ]

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", cidr))
    ])
    error_message = "Mỗi phần tử trong 'public_subnet_cidrs' phải là một dải CIDR hợp lệ."
  }
}

variable "private_subnet_cidrs_web" {
  description = "Danh sách các dải IP CIDR cho private subnets (cho Web EC2)."
  type        = list(string)
  default = [
    "10.0.10.0/24", # Đặt ở Availability Zone A
    "10.0.11.0/24"  # Đặt ở Availability Zone B
  ]

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs_web : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", cidr))
    ])
    error_message = "Mỗi phần tử trong 'private_subnet_cidrs_web' phải là một dải CIDR hợp lệ."
  }
}

variable "private_subnet_cidrs_db" {
  description = "Danh sách các dải IP CIDR cho private subnets (cho DB RDS)."
  type        = list(string)
  default = [
    "10.0.20.0/24", # Đặt ở Availability Zone A
    "10.0.21.0/24"  # Đặt ở Availability Zone B
  ]

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs_db : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", cidr))
    ])
    error_message = "Mỗi phần tử trong 'private_subnet_cidrs_db' phải là một dải CIDR hợp lệ."
  }
}

# BIẾN (VARIABLES) CHO BẢO MẬT (SECURITY)
variable "my_ip" {
  description = "Địa chỉ IP public của máy để SSH. Thêm /32 vào cuối."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}\\/32$", var.my_ip))
    error_message = "Giá trị 'my_ip' phải là một IP duy nhất có /32 (ví dụ: 1.2.3.4/32)."
  }
}

variable "db_port" {
  description = "Cổng (port) của cơ sở dữ liệu."
  type        = number
  default     = 5432 

  validation {
    condition     = var.db_port > 1024 && var.db_port < 65535
    error_message = "Cổng CSDL phải là một số hợp lệ."
  }
}

# BIẾN (VARIABLES) CHO CƠ SỞ DỮ LIỆU (DATABASE)
variable "db_name" {
  description = "Tên của CSDL khởi tạo ban đầu."
  type        = string
  default     = "webappdb"
}

variable "db_username" {
  description = "Tên đăng nhập cho CSDL."
  type        = string
  sensitive   = true 
}

variable "db_password" {
  description = "Mật khẩu cho CSDL."
  type        = string
  sensitive   = true 
}

variable "db_instance_class" {
  description = "Phiên bản Instance."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine" {
  description = "Loại CSDL."
  type        = string
  default     = "postgres" 
}

variable "db_engine_version" {
  description = "Phiên bản CSDL."
  type        = string
  default     = "16.3" 
}

# BIẾN (VARIABLES) CHO WEB TIER (EC2)

variable "ec2_instance_class" {
  description = "Loại máy chủ cho Web Tier."
  type        = string
  default     = "t3.micro"
}

variable "web_asg_min_size" {
  description = "Số lượng máy chủ EC2 tối thiểu."
  type        = number
  default     = 2
}

variable "web_asg_max_size" {
  description = "Số lượng máy chủ EC2 tối đa."
  type        = number
  default     = 4
}

variable "web_asg_desired_capacity" {
  description = "Số lượng máy chủ EC2 mong muốn ban đầu."
  type        = number
  default     = 2
}
