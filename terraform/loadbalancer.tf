# 1. TẠO APPLICATION LOAD BALANCER (ALB)
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  drop_invalid_header_fields = true

  tags = {
    Name = "${var.environment}-alb"
  }
}

# 2. TẠO NHÓM MỤC TIÊU CHO WEB TIER
resource "aws_lb_target_group" "web" {
  name        = "${var.environment}-web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance" 

  health_check {
    enabled             = true
    path                = "/" 
    protocol            = "HTTP"
    port                = "traffic-port" 
    healthy_threshold   = 2 
    unhealthy_threshold = 2 
    timeout             = 5 
    interval            = 10 
  }

  tags = {
    Name = "${var.environment}-web-tg"
  }
}

# 3. TẠO BỘ LẮNG NGHE CHO ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}



