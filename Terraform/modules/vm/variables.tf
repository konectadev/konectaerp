variable "name" {
  description = "VM name"
  type        = string
}

variable "vpc" {
  description = "VPC name"
  type        = string
}

variable "subnet" {
  description = "Subnet name"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP"
  type        = bool
  default     = false
}

variable "machine_type" {
  description = "Machine Type"
  type        = string
  default = "e2-micro"
}

variable "region" {
  description = "Machine Region"
  type        = string
  default = "us-east1-b"
}