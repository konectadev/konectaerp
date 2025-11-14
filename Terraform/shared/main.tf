provider "google" {
  project = var.project_id
  region  = var.region
}

module "service_account" {
  source = "../modules/service_account"
  account_id   = "cloud-run-services"
  display_name = "Cloud Run Services SA"
  project_id   = var.project_id
  roles = [
    "roles/run.invoker",
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client"
  ]
}

module "artifact_repo" {
  source = "../modules/artifact_registry"
  region = var.region
  project_id = var.project_id
  repository_id = "erp"
}

module "vpc_connector" {
  source = "../modules/vpc_connector"
  name = "erp-serverless-connector"
  region = var.region
  network = "default"
  ip_cidr_range = "10.8.1.0/28"
}
