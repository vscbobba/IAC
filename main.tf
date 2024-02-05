module "Network"{
    source = "./Modules/Network"
}
resource "aws_instance" "bastion" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.Public_subnet1
}
resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.Public_subnet1
}
resource "aws_instance" "DB" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet1
}
resource "aws_instance" "backend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet2
}