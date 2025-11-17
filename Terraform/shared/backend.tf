terraform {
  backend "gcs" {
    bucket = "konecta-erp-system"
    prefix = "shared"
  }
}
