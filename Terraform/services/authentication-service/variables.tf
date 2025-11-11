variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "konecta-task-467513"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "image_tag" {
  description = "Image tag"
  type        = string
  default     = "latest"
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

variable "repo_url" {
  description = "Url for repo artifact"
  type= string
  default = "us-east1-docker.pkg.dev/konecta-task-467513/erp"
}