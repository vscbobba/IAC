module "Network"{
    source = "./Modules/Network"
}

resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.Network.ALB_SG]  # Replace with the security group for the ALB
  subnets            = [module.Network.Public_subnet2, module.Network.Public_subnet]  # Specify your public subnets
  enable_deletion_protection = false  # Set to true if you want to enable deletion protection

  enable_http2      = true
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.Network.VPC_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "80"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_autoscaling_attachment" "frontend_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  #alb_target_group_arn   = aws_lb_target_group.frontend_tg.arn
}

resource "aws_launch_configuration" "frontend_lc" {
  name = "frontend-lc"
  image_id = var.ami
  instance_type = var.inst
  security_groups = [module.Network.SG]
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              sudo rm -rf /usr/share/nginx/html/*
              sudo curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/frontend.zip
              sudo unzip /tmp/frontend.zip -d /usr/share/nginx/html/
              sudo touch /root/expense.conf
              sudo tee -a /root/expense.conf <<EOL
              proxy_http_version 1.1;
              location /api/ { proxy_pass http://localhost:8080/; }
              location /health {
                  stub_status on;
                  access_log off;
              }
              EOL
              sudo cp /root/expense.conf /etc/nginx/default.d/expense.conf
              sudo systemctl restart nginx
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "frontend_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.frontend_lc.id
  vpc_zone_identifier  = [module.Network.priv_subnet1]  # Use your private subnet

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true

  tag {
    key                 = "Name"
    value               = "frontend-instance"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.public_subnet
}

resource "aws_vpc_peering_connection" "VPC_peer" {
  vpc_id          = "vpc-013b83a7327f3ca6a"
  peer_vpc_id     = module.Network.IAC
} 
resource "aws_vpc_peering_connection_accepter" "example" {
  provider          = aws
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_peer.id
}

resource "aws_route" "workstation_to_ec2" {
  route_table_id         = "rtb-06e7d4ebf3b36ee61"
  destination_cidr_block = module.Network.IAC_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_peer.id
}
resource "aws_route" "ec2_to_workstation" {
  route_table_id         = module.Network.routable
  destination_cidr_block = "30.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.example.id
}
