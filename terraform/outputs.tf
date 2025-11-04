# OUTPUTS CHO VPC
output "vpc_id" {
  description = "ID của VPC chính."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "Dải IP CIDR của VPC chính."
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_security_group_id" {
  description = "ID của Security Group mặc định trong VPC."
  value       = aws_vpc.main.default_security_group_id
}

# OUTPUTS CHO SUBNETS
output "public_subnet_ids" {
  description = "Danh sách ID của các public subnets."
  value = aws_subnet.public.*.id
}

output "private_web_subnet_ids" {
  description = "Danh sách ID của các private subnets cho Web."
  value       = aws_subnet.private_web.*.id
}

output "private_db_subnet_ids" {
  description = "Danh sách ID của các private subnets cho Database."
  value       = aws_subnet.private_db.*.id
}

# OUTPUTS CHO NETWORKING 
output "nat_gateway_public_ips" {
  description = "Danh sách các IP Public của NAT Gateways HA."
  value       = aws_eip.nat.*.public_ip
}

output "private_route_table_ids" {
  description = "Danh sách ID của các bảng định tuyến private (cho mỗi AZ)."
  value       = aws_route_table.private.*.id
}

# OUTPUTS CHO AVAILABILITY ZONES
output "availability_zones" {
  description = "Danh sách các Availability Zones (AZs) đang được sử dụng."
  value       = data.aws_availability_zones.available.names
}

