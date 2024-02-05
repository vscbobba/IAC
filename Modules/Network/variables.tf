variable "vpc_cidr" {
    default = ""
    type = string
}
variable "public_cidr_1" {
    default = ""
    type = string
}
variable "public_cidr_2" {
    default = ""
    type = string
}
variable "Priv_sn1" {
    default = ""
    type = string
}
variable "Priv_sn2" {
    default = ""
    type = string
}
variable "Priv_sn3" {
    default = ""
    type = string
}
variable "port" {
   type = list(number)
   default = [22,8080,80]
}
variable "ami" {
  type = string
  default = ""
}

variable "inst" {
  type = string
  default = ""
}