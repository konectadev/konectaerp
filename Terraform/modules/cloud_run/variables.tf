variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "image" {
  description = "Container image URL"
  type        = string
}

variable "port" {
  description = "Container port"
  type        = number
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "auth" {
  description = "Authentication type: public or private"
  type        = string
  default     = "private"
}

variable "by_req" {
  description = "CPU idle setting"
  type        = bool
  default     = true
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "ingress" {
  description = "Ingress traffic settings"
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

variable "vpc_connector" {
  description = "VPC connector"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from Secret Manager"
  type        = map(string)
  default     = {}
}