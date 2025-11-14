variable "region" {
  type        = string
  description = "The GCP region where resources will be deployed"
}

variable "repository_id" {
  type        = string
  description = "The Artifact Registry repository ID for container images"
  default     = "erp"
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created"
}
