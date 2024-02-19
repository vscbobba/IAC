module "Network"{
    source = "./Modules/Network"
}
data "aws_iam_role" "ws-role"{
    name = "Ec2-full"
}
resource "aws_instance" "workstation" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.Public_subnet1
    iam_instance_profile = data.aws_iam_role.ws-role.name
    tags = {
      Name = "workstation"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname workstation
              sudo dnf install ansible -y
              sudo git clone https://github.com/vscbobba/IAC.git
              cd /IAC
              sudo git pull origin jenkins
              sudo chmod 777 /etc/ansible/hosts
              sudo echo "workstation ansible_host=workstation.bobbascloud.online ansible_user=centos ansible_ssh_pass=DevOps321">>/etc/ansible/hosts
              #sudo ansible-playbook Ansible/playbook.yml -e role_name=frontend -e anshost=workstation
              EOF
}
# resource "aws_instance" "frontend" {
#     ami = var.ami
#     instance_type = var.inst
#     security_groups = [module.Network.SG]
#     iam_instance_profile = data.aws_iam_role.example-role.name
#     subnet_id = module.Network.Public_subnet1
#     tags ={
#         Name = "frontend"
#     }
#     user_data = <<-EOF
#               #!/bin/bash
#               sudo set-hostname frontend
#               EOF
# }
# resource "aws_instance" "DB" {
#     ami = var.ami
#     instance_type = var.inst
#     security_groups = [module.Network.SG]
#     subnet_id = module.Network.priv_subnet1
#     iam_instance_profile = data.aws_iam_role.example-role.name
#     tags = {
#       Name = "DB"
#     }
#     user_data = <<-EOF
#               #!/bin/bash
#               sudo set-hostname DB
#               EOF
# }
# resource "aws_instance" "backend" {
#     ami = var.ami
#     instance_type = var.inst
#     security_groups = [module.Network.SG]
#     subnet_id = module.Network.priv_subnet2
#     iam_instance_profile = data.aws_iam_role.example-role.name
#     tags = {
#       Name = "backend"
#     }
#     user_data = <<-EOF
#              #!/bin/bash
#              sudo set-hostname backend
#              EOF
# }

data "aws_route53_zone" "hostedzone" {
  name = "bobbascloud.online"
}
resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.hostedzone.zone_id
  name    = "workstation"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.workstation.public_ip]
}
