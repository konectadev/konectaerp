provider "google" {
  project = var.project_id
  region  = var.region
}

data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "shared"
  }
}

module "service_account" {
  source       = "../modules/service_account"
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
  source        = "../modules/artifact_registry"
  region        = var.region
  project_id    = var.project_id
  repository_id = "erp"
}

module "rabbitmq" {
  source = "../modules/cloud_run"

  service_name          = "rabbitmq"
  project_id            = var.project_id
  region                = var.region
  image                 = "rabbitmq:3.13-management"
  port                  = 15672
  service_account_email = module.service_account.email
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  environment_variables = {
    RABBITMQ_DEFAULT_USER = "guest"
    RABBITMQ_DEFAULT_PASS = "guest"
  }
  min_instances = 1
  max_instances = 1
  vpc_connector = google_vpc_access_connector.serverless_connector.name
}

module "mailhog" {
  source = "../modules/cloud_run"

  service_name  = "mailhog"
  project_id    = var.project_id
  region        = var.region
  image         = "mailhog/mailhog:v1.0.1"
  port          = 8025
  auth          = "private"
  ingress       = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  min_instances = 1
  max_instances = 1
  # service_account_email = var.service_account_email
  vpc_connector = google_vpc_access_connector.serverless_connector.name
}

module "consul" {
  source = "../modules/cloud_run"

  service_name = "consul"
  region       = var.region
  project_id   = var.project_id

  image                 = "hashicorp/consul:1.18"
  port                  = 8500
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  environment_variables = {}
  custom_args           = ["agent", "-server", "-bootstrap", "-ui", "-client=0.0.0.0"]
  min_instances         = 1
  max_instances         = 1
  service_account_email = module.service_account.email
  vpc_connector         = google_vpc_access_connector.serverless_connector.name
}
