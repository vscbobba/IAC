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