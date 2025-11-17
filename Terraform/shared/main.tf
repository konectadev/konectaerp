provider "google" {
  project = var.project_id
  region  = var.region
}

data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp"
    prefix = "shared"
  }
}

module "rabbitmq" {
  source = "../../modules/cloud_run"

  service_name = "rabbitmq"
  region       = data.terraform_remote_state.shared.outputs.region
  image        = "${var.repo_url}/rabbitmq:${var.image_tag}"
  port         = 15672
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "rabbitmq"
    SPRING__CLOUD__CONFIG__URI = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
  }
}

module "mailhog" {
  source = "../../modules/cloud_run"

  service_name = "mailhog"
  region       = data.terraform_remote_state.shared.outputs.region
  image        = "${var.repo_url}/mailhog:${var.image_tag}"
  port         = 8025
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "mailhog"
    SPRING__CLOUD__CONFIG__URI = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
  }
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

