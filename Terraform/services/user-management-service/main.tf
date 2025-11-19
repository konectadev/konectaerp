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


module "user_management_service" {
  source = "../../modules/cloud_run"

  service_name          = "user-management-service"
  region                = data.terraform_remote_state.shared.outputs.region
  project_id            = data.terraform_remote_state.shared.outputs.project_id
  image                 = "${var.repo_url}/user-management-service:${var.image_tag}"
  port                  = 5078
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector         = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth          = "private"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress       = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT          = "Production"
    SERVICE_NAME                    = "user-management-service"
    SPRING__CLOUD__CONFIG__URI      = data.terraform_remote_state.config-server.outputs.uri
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    SPRING__APPLICATION__NAME       = "user-management-service"
  }
}
