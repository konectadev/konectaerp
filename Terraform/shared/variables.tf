variable "project_id" {
  type    = string
  default = "konecta-task-467513"
}

variable "region" {
  type    = string
  default = "us-east1"
}


variable "repo_url" {
  type    = string
  default = "us-east1-docker.pkg.dev/konecta-task-467513/erp"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 3
}
