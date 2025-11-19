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



module "authentication_service" {
  source = "../../modules/cloud_run"

  service_name          = "authentication-service"
  region                = data.terraform_remote_state.shared.outputs.region
  project_id            = data.terraform_remote_state.shared.outputs.project_id
  image                 = "${var.repo_url}/authentication-service:${var.image_tag}"
  port                  = 7280
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector         = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth          = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress       = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT          = "Production"
    SERVICE_NAME                    = "authentication-service"
    SPRING__CLOUD__CONFIG__URI      = data.terraform_remote_state.config-server.outputs.uri
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    ASPNETCORE_URLS                 = "http://+:7280"
  }
}
