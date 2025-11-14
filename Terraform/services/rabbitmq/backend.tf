terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.10.0"
    }
  }
  backend "gcs" {
    bucket = "konecta-erp"
    prefix = "services/rabbitmq"
  }
}
