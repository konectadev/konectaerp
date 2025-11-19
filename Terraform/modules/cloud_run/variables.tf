variable "service_name" {
  type        = string
  description = "The name of the Cloud Run service"
}

variable "image" {
  type        = string
  description = "The container image to deploy"
}

variable "project_id" {
  type = string
}

variable "region" {
  type        = string
  description = "The GCP region"
}

variable "deletion_protection" {
  type = bool
  default = false
}

variable "port" {
  type        = number
  description = "The port the container listens on"
  default     = 8080
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to set in the container"
  default     = {}
}

variable "min_instances" {
  type        = number
  description = "Minimum number of instances"
  default     = 0
}

variable "max_instances" {
  type        = number
  description = "Maximum number of instances"
  default     = 3
}

variable "auth" {
  type        = string
  description = "Service access: 'public' or 'private'"
  default     = "private"
}

variable "ingress" {
  type        = string
  description = "Ingress setting for the Cloud Run service"
  default     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

variable "service_account_email" {
  type        = string
  description = "Service account email for Cloud Run"
  default     = ""
}

variable "vpc_connector" {
  type        = string
  description = "VPC connector name (if needed)"
  default     = ""
}

variable "vpc_egress" {
  type        = string
  description = "VPC egress setting"
  default     = "ALL_TRAFFIC"
}

variable "custom_args" {
  type        = list(string)
  description = "Custom arguments to pass to the container"
  default     = []
}

variable "cpu_limit" {
  type        = string
  description = "CPU limit for the container"
  default     = "1"
}

variable "memory_limit" {
  type        = string
  description = "Memory limit for the container"
  default     = "512Mi"
}
