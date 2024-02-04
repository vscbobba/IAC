variable "vpc_cidr" {
    default = "20.0.0.0/16"
    type = string
}
variable "public_cidr" {
    default = "20.0.10.0/24"
    type = string
}

variable "Priv_sn1" {
    default = "20.0.1.0/24"
    type = string
}
variable "Priv_sn2" {
    default = "20.0.2.0/24"
    type = string
}
variable "Priv_sn3" {
    default = "20.0.3.0/24"
    type = string
}
variable "port" {
  type = list(string)
  default = ["22","8080","80"]
}
variable "ami" {
  type = string
  default = "ami-0f3c7d07486cad139"
}

variable "inst" {
  type = string
  default = "t3.micro"
}