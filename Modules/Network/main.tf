resource "aws_vpc" "IAC" {
    cidr_block=var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
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