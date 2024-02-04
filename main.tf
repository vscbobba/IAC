resource "aws_vpc" "IAC" {
    cidr_block=var.vpc_cidr
    tags = {
        name = "MyVPC"
    }   
}

resource "aws_subnet" "Public_subnet" {
   cidr_block = var.public_cidr
   vpc_id = aws_vpc.IAC.id
   map_public_ip_on_launch = true
   tags ={
    Name = "MyPub"
   }
}

resource "aws_subnet" "Private_subnet1" {
   cidr_block = var.Priv_sn1
   vpc_id = aws_vpc.IAC.id
   tags ={
    Name = "MyPriv1"
   }
}
resource "aws_subnet" "Private_subnet2" {
   cidr_block = var.Priv_sn2
   vpc_id = aws_vpc.IAC.id
   tags ={
    Name = "MyPriv2"
   }
}
resource "aws_subnet" "Private_subnet3" {
   cidr_block = var.Priv_sn3
   vpc_id = aws_vpc.IAC.id
   tags ={
    Name = "MyPriv3"
   }
}

resource "aws_internet_gateway" "MY_IGW"{
    vpc_id = aws_vpc.IAC.id
    tags ={
        Name = "MY-IGW"
    }
}
resource "aws_route_table" "Main" {
   vpc_id = aws_vpc.IAC.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MY_IGW.id
   }  
}
resource "aws_route_table_association" "pub_subnet_associate" {
    subnet_id = aws_subnet.Public_subnet.id
    route_table_id = aws_route_table.Main.id  
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.IAC.id
  dynamic ingress {
    iterator = port
    for_each = var.port
    content{  
          description      = "TLS from VPC"
          from_port        = port.value
          to_port          = port.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [aws_security_group.allow_tls.id]
    subnet_id = aws_subnet.Private_subnet1.id
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
  peer_vpc_id     = aws_vpc.IAC.id
}
resource "aws_vpc_peering_connection_accepter" "example" {
  provider          = aws
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_peer.id
}

resource "aws_route" "workstation_to_ec2" {
  route_table_id         = "rtb-06e7d4ebf3b36ee61"
  destination_cidr_block = aws_subnet.Private_subnet1.id
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_peer.id
}
resource "aws_route" "ec2_to_workstation" {
  route_table_id         = aws_route_table.Main.id
  destination_cidr_block = "30.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.example.id
}
