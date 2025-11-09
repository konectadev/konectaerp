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

variable "image_tag" {
  description = "Docker image tag (usually git SHA)"
  type        = string
  default     = "latest"
}

variable "min_instances" {
  description = "Minimum instances for Cloud Run services"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum instances for Cloud Run services"
  type        = number
  default     = 3
}

variable "service_account_email" {
  description = "Service account email for Cloud Run"
  type        = string
  default     = "terraform@konecta-task-467513.iam.gserviceaccount.com"
}

variable "vpc_connector" {
  description = "VPC connector for private services"
  type        = string
  default     = ""
}

variable "vpc_network" {
  description = "VPC network for Cloud SQL"
  type        = string
  default     = "projects/konecta-task-467513/global/networks/default"
}

variable "consul_host" {
  description = "Consul host for service discovery"
  type        = string
  default     = "consul-server.consul.svc.cluster.local"
}

variable "image_repository_name" {
  description = "Name of the image repository"
  type        = string
  default     = "konecta-erp"
}