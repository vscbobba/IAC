module "Network"{
    source = "./Modules/Network"
}
resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet1
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
  destination_cidr_block = module.Network.priv_subnet1
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_peer.id
}
resource "aws_route" "ec2_to_workstation" {
  route_table_id         = module.Network.routable
  destination_cidr_block = "30.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.example.id
}
