variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "name" {
  description = "Name of the project"
  type        = string
  default     = "skillup"
}

variable "azs" {
  default = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "public_subnets" {
  type = map(string)
  default = {
    ap-northeast-2a = "10.0.0.0/24",
    ap-northeast-2b = "10.0.1.0/24",
    ap-northeast-2c = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  type = map(string)
  default = {
    ap-northeast-2a = "10.0.10.0/24",
    ap-northeast-2b = "10.0.11.0/24",
    ap-northeast-2c = "10.0.12.0/24"
  }
}
