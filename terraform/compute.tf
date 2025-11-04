# 1. TẠO IAM ROLE CHO EC2
resource "aws_iam_role" "web_ec2_role" {
  name = "${var.environment}-web-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-web-ec2-role"
  }
}

resource "aws_iam_instance_profile" "web_ec2_profile" {
  name = "${var.environment}-web-ec2-profile"
  role = aws_iam_role.web_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.web_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 2. TẠO KHUÔN MÁY CHỦ (LAUNCH TEMPLATE)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix            = "${var.environment}-web-"
  image_id               = data.aws_ami.amazon_linux_2023.id 
  instance_type          = var.ec2_instance_class
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.web_ec2_profile.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>OK from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
  )

  network_interfaces {
    associate_public_ip_address = false
  }

  tags = {
    Name = "${var.environment}-web-lt"
  }
}

# 3. TẠO NHÓM TỰ ĐỘNG CO GIÃN
resource "aws_autoscaling_group" "web" {
  name_prefix = "${var.environment}-web-asg-"

  min_size         = var.web_asg_min_size
  max_size         = var.web_asg_max_size
  desired_capacity = var.web_asg_desired_capacity

  vpc_zone_identifier = aws_subnet.private_web.*.id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest" 
  }

  target_group_arns = [aws_lb_target_group.web.arn]
  
  health_check_type         = "ELB"
  health_check_grace_period = 120  

  depends_on = [aws_lb_target_group.web]

  tags = [
    {
      key                 = "Name"
      value               = "${var.environment}-web-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = var.owner_email
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "NT542.Q11-Terraform" 
      propagate_at_launch = true
    }
  ]
}

