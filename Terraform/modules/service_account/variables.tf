variable "account_id" {
  type        = string
  description = "The ID of the service account"
}

variable "display_name" {
  type        = string
  description = "The display name for the service account"
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where the service account will be created"
}

variable "roles" {
  type        = list(string)
  description = "List of IAM roles to assign to the service account"
  default     = []
}
