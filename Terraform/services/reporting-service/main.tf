data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "shared"
  }
}

data "terraform_remote_state" "config-server" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/config-server-service"
  }
}

module "reporting_service" {
  source = "../../modules/cloud_run"

  service_name = "reporting-service"
  region       = data.terraform_remote_state.shared.outputs.region
  image        = "${var.repo_url}/reporting-service:${var.image_tag}"
  project_id = data.terraform_remote_state.shared.outputs.project_id

  port         = 8085
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "reporting-service"
    SPRING__CLOUD__CONFIG__URI = data.terraform_remote_state.config-server.outputs.uri
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    SPRING__APPLICATION__NAME = "reporting-service"
  }
}
