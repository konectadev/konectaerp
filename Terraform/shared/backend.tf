terraform {
  backend "gcs" {
    bucket = "konecta-erp"
    prefix = "shared"
  }
}
