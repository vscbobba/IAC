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
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname workstation
              sudo dnf install ansible -y
              sudo yum install -y yum-utils
              sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
              sudo yum -y install terraform
              EOF
}
resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    iam_instance_profile = data.aws_iam_role.example-role.name
    subnet_id = module.Network.Public_subnet1
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname frontend
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
resource "aws_instance" "DB" {
    ami = var.ami
    instance_type = var.inst
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet1
    iam_instance_profile = data.aws_iam_role.example-role.name
    user_data = <<-EOF
              #!/bin/bash
              sudo set-hostname DB
              sudo dnf module disable mysql -y
              sudo tee -a /root/mysql.repo <<EOL
              [mysql]
              name=MySQL 5.7 Community Server
              baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/\$basearch/
              enabled=1
              gpgcheck=0
              EOL
              sudo cp /root/mysql.repo /etc/yum.repos.d/mysql.repo
              sudo dnf install mysql-community-server -y
              sudo systemctl enable mysqld
              sudo systemctl start mysqld
              db_password=$(aws ssm get-parameter --name "/expense-app/db_password" --with-decryption --query "Parameter.Value" --output text)
              sudo mysql_secure_installation --set-root-pass $db_password
              EOF
}
resource "aws_instance" "backend" {
    ami = var.ami
    instance_type = "t3.medium"
    security_groups = [module.Network.SG]
    subnet_id = module.Network.priv_subnet2
    iam_instance_profile = data.aws_iam_role.example-role.name
    user_data = <<-EOF
             #!/bin/bash
             sudo set-hostname backend
             sudo dnf module disable nodejs -y
             sudo dnf module enable nodejs:18 -y
             sudo dnf install nodejs -y
             sudo dnf install mysql -y
             sudo useradd expense
             sudo mkdir /app
             sudo curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/backend.zip 
             sudo unzip /tmp/backend.zip -d /app/
             cd /app 
             sudo npm install
             sudo tee -a /root/backend.service <<EOL
              [Unit]
              Description = Backend Service

              [Service]
              User=expense
              Environment=DB_HOST="<MYSQL-SERVER-IPADDRESS>"
              ExecStart=/bin/node /app/index.js
              SyslogIdentifier=backend

              [Install]
              WantedBy=multi-user.target
              EOL
              sudo cp /root/backend.service /etc/systemd/system/backend.service
              sudo systemctl daemon-reload
              sudo systemctl enable backend 
              sudo systemctl start backend
              db_password=$(aws ssm get-parameter --name "/expense-app/db_password" --with-decryption --query "Parameter.Value" --output text)
              sudo mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -p$db_password < /app/schema/backend.sql 
              EOF
}

data "aws_route53_zone" "hostedzone" {
  name = "bobbascloud.online"
}
resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.hostedzone.zone_id
  name    = "frontend.dev"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.frontend.public_ip]
}
resource "aws_route53_record" "DB" {
  zone_id = data.aws_route53_zone.hostedzone.zone_id
  name    = "DB.dev"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.DB.public_ip]
}
resource "aws_route53_record" "backend" {
  zone_id = data.aws_route53_zone.hostedzone.zone_id
  name    = "backend.dev"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.backend.public_ip]
}