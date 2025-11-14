data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp"
    prefix = "shared"
  }
}

module "finance_service" {
  source = "../../modules/cloud_run"

  service_name = "finance-service"
  region       = data.terraform_remote_state.shared.outputs.region
  image        = "${var.repo_url}/finance-service:${var.image_tag}"
  port         = 5003
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "finance-service"
    SPRING__CLOUD__CONFIG__URI = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    SPRING__APPLICATION__NAME = "finance-service"
  }
}
