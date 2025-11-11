terraform {
   required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.10.0"
    }
  }
  backend "gcs" {
    bucket      = "konecta-erp"
    prefix      = "services/authentication-service"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
