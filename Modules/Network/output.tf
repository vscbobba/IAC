output "SG" {
    value = aws_security_group.allow_tls.id
}

output "priv_subnet1"{
    value = aws_subnet.Private_subnet1.id
}

output "IAC" {
  value = aws_vpc.IAC.id
}

output "routable" {
    value = aws_route_table.Main.id
}