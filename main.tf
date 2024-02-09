module "Network"{
    source = "./Modules/Network"
}
data "aws_iam_role" "example-role"{
    name = "Ec2-full"
}
resource "aws_instance" "workstation" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.Public_subnet1
    iam_instance_profile = data.aws_iam_role.example-role.name
    tags = {
      Name = "workstation"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname workstation
              sudo dnf install ansible -y
              sudo yum install -y yum-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
              sudo yum -y install terraform
              sudo dnf install -y java-11-openjdk-devel
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
              sudo curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo dnf install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
              sudo firewall-cmd --reload
              EOF
}
# resource "aws_instance" "jenkins" {
#     ami = var.ami
#     instance_type = var.inst
#     security_groups = [module.Network.SG]
#     subnet_id = module.Network.Public_subnet1
#     iam_instance_profile = data.aws_iam_role.example-role.name
#     tags = {
#       Name = "jenkins"
#     }
#     user_data = <<-EOF
#               #!/bin/bash
#               sudo set-hostname jenkins
#               sudo dnf install -y java-11-openjdk-devel
#               sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
#               sudo curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
#               sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#               sudo dnf install -y jenkins
#               sudo systemctl start jenkins
#               sudo systemctl enable jenkins
#               sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
#               sudo firewall-cmd --reload
#               EOF
# }   

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
