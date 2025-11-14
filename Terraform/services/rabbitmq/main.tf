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
