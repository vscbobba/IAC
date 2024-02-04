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