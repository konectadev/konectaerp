terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.10.0"
    }
  }
  backend "gcs" {
    bucket = "konecta-erp-system"
    prefix = "services/api-gateway"
  }
}
