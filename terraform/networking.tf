# LẤY THÔNG TIN AVAILABILITY ZONES (AZs) TỰ ĐỘNG
data "aws_availability_zones" "available" {
  state = "available"
}

# TẠO VPC (VIRTUAL PRIVATE CLOUD)
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# TẠO INTERNET GATEWAY 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# TẠO PUBLIC SUBNETS (CHO ALB VÀ NAT GATEWAYS)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true 

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# TẠO NAT GATEWAY HA 
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs) 

  depends_on = [aws_internet_gateway.main]
}

# Đặt mỗi NAT GW vào một public subnet khác nhau
resource "aws_nat_gateway" "main" {
  count = length(var.public_subnet_cidrs) 

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id 

  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# TẠO PRIVATE SUBNETS (CHO WEB EC2)
resource "aws_subnet" "private_web" {
  count = length(var.private_subnet_cidrs_web)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs_web[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false 

  tags = {
    Name = "${var.environment}-private-web-subnet-${count.index + 1}"
  }
}

# TẠO PRIVATE SUBNETS (CHO DB RDS)
resource "aws_subnet" "private_db" {
  count = length(var.private_subnet_cidrs_db)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs_db[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false 

  tags = {
    Name = "${var.environment}-private-db-subnet-${count.index + 1}"
  }
}

# TẠO BẢNG ĐỊNH TUYẾN 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  count = length(var.public_subnet_cidrs) 
  
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

# GÁN BẢNG ĐỊNH TUYẾN 
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_web" {
  count = length(var.private_subnet_cidrs_web)

  subnet_id      = aws_subnet.private_web[count.index].id
  route_table_id = aws_route_table.private[count.index].id 
}

resource "aws_route_table_association" "private_db" {
  count = length(var.private_subnet_cidrs_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[count.index].id 
}

