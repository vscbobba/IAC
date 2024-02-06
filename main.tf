module "Network"{
    source = "./Modules/Network"
}
data "aws_iam_role" "example-role"{
    name = "Ec2-full"
}
resource "aws_instance" "bastion" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.Public_subnet1
    iam_instance_profile = data.aws_iam_role.example-role.name
    tags = {
      Name = "bastion"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname workstation
              sudo dnf install ansible -y
              sudo yum install -y yum-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
              sudo yum -y install terraform
              sudo cat /root/IAC/Ansible/inventory-info >>/etc/ansible/hosts
              EOF
}
resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    iam_instance_profile = data.aws_iam_role.example-role.name
    subnet_id = module.Network.Public_subnet1
    tags ={
        Name = "frontend"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname frontend
              EOF
}
resource "aws_instance" "DB" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet1
    iam_instance_profile = data.aws_iam_role.example-role.name
    tags = {
      Name = "DB"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname DB
              EOF
}
resource "aws_instance" "backend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet2
    iam_instance_profile = data.aws_iam_role.example-role.name
    tags = {
      Name = "backend"
    }
    user_data = <<-EOF
             #!/bin/bash
             sudo set-hostname backend
             EOF
}