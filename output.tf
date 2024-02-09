output "jenkins_ip" {
  value = aws_instance.workstation.public_ip
}