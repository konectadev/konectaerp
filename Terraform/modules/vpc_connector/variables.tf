variable "name" {
  type    = string
  default = "erp-serverless-connector"
}

variable "region" {
  type = string
}

variable "network" {
  type    = string
  default = "default"
}

variable "ip_cidr_range" {
  type    = string
  default = "10.8.1.0/28"
}
