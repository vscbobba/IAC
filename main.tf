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

