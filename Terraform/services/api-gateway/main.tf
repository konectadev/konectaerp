data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp"
    prefix = "shared"
  }
}

module "api_gateway" {
  source = "../../modules/cloud_run"

  service_name = "api-gateway"
  region       = data.terraform_remote_state.shared.outputs.region
  image        = "${var.repo_url}/api-gateway:${var.image_tag}"
  port         = 8080
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth = "public"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_ALL"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "api-gateway"
    SPRING__CLOUD__CONFIG__URI = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    SPRING_APPLICATION_NAME = "api-gateway"
    AUTH_SERVICE_URI = "http://authentication-service:7280"
    HR_SERVICE_URI = "http://hr-service:5005"
    USER_MANAGEMENT_SERVICE_URI = "http://user-management-service:5078"
    INVENTORY_SERVICE_URI = "http://inventory-service:5020"
    FINANCE_SERVICE_URI = "http://finance-service:5003"
    REPORTING_SERVICE_URI = "http://reporting-service:8085"
  }
}
