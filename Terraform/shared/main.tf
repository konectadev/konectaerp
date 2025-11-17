provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "erp_vpc" {
  name                    = "erp-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "erp_subnet" {
  name          = "erp-subnet"
  ip_cidr_range = "10.8.0.0/24"
  region        = var.region
  network       = google_compute_network.erp_vpc.id
}

resource "google_vpc_access_connector" "serverless_connector" {
  name          = "erp-serverless-connector"
  region        = var.region
  network       = google_compute_network.erp_vpc.name
  ip_cidr_range = "10.8.1.0/28" # small block for connector
}


data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp"
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
  region                = var.region
  image                 = "rabbitmq:3.13-management"
  port                  = 15672
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  environment_variables = {
    ASPNETCORE_ENVIRONMENT          = "Production"
    SERVICE_NAME                    = "rabbitmq"
    SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    RABBITMQ_DEFAULT_USER           = "guest"
    RABBITMQ_DEFAULT_PASS           = "guest"
  }
  min_instances = 1
  max_instances = 1
  vpc_connector = google_vpc_access_connector.serverless_connector.name
}

module "mailhog" {
  source = "../modules/cloud_run"

  service_name          = "mailhog"
  region                = var.region
  image                 = "mailhog/mailhog:v1.0.1"
  port                  = 8025
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  min_instances         = 0
  max_instances         = 1
  # service_account_email = var.service_account_email
  vpc_connector         = google_vpc_access_connector.serverless_connector.name
}

module "config_server" {
  source = "../modules/cloud_run"

  service_name          = "config-server"
  region                = var.region
  image                 = "${var.repo_url}/config-server:${var.image_tag}"
  port                  = 8888
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  service_account_email = module.service_account.email
  vpc_connector         = google_vpc_access_connector.serverless_connector.name
  min_instances         = 1
  max_instances         = 1
  environment_variables = {
    SERVER_PORT = "8888"
    CONSUL_HOST = "consul"
    CONSUL_PORT = "8500"
    CONSUL_ENDPOINT = "http://consul:8500"
  }
  depends_on = [
    module.consul
  ]
}
