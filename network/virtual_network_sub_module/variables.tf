variable "resource_group" {
  type = any
}

variable "virtual_network_cidr" {
  type = string
}

variable "prefix" {
  type    = list(string)
  default = []
}

variable "suffix" {
  type    = list(string)
  default = []
}



