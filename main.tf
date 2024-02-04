resource "aws_vpc" "IAC" {
    cidr_block=var.vpc_cidr
    tags = {
        name = "MyVPC"
    }   
}