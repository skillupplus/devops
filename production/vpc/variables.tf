variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "name" {
  type    = string
  default = "skillup-production"
}

variable "ap_northeast_2a_public_network" {
  type    = number
  default = 0
}

variable "ap_northeast_2c_public_network" {
  type    = number
  default = 1
}

variable "ap_northeast_2a_private_network" {
  type    = number
  default = 10
}

variable "ap_northeast_2c_private_network" {
  type    = number
  default = 11
}
