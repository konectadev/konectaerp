data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "shared"
  }
}

data "terraform_remote_state" "authentication_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/authentication-service"
  }
}

data "terraform_remote_state" "finance_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/finance-service"
  }
}

data "terraform_remote_state" "hr_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/hr-service"
  }
}

data "terraform_remote_state" "inventory_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/inventory-service"
  }
}

data "terraform_remote_state" "reporting_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/reporting-service"
  }
}

data "terraform_remote_state" "user_management_service" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/user-management-service"
  }
}

data "terraform_remote_state" "config_server" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "services/config-server"
  }
}


module "api_gateway" {
  source = "../../modules/cloud_run"

  service_name          = "api-gateway"
  region                = data.terraform_remote_state.shared.outputs.region
  project_id            = data.terraform_remote_state.shared.outputs.project_id
  image                 = "${var.repo_url}/api-gateway:${var.image_tag}"
  port                  = 8080
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector         = data.terraform_remote_state.shared.outputs.vpc_connector_name

  auth          = "public"
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress       = "INGRESS_TRAFFIC_ALL"

  environment_variables = {
    ASPNETCORE_ENVIRONMENT     = "Production"
    SERVICE_NAME               = "api-gateway"
    SPRING__CLOUD__CONFIG__URI = data.terraform_remote_state.config_server.outputs.uri

    SPRING__CLOUD__CONFIG__FAILFAST = "false"
    SPRING_APPLICATION_NAME         = "api-gateway"
    AUTH_SERVICE_URI                = data.terraform_remote_state.authentication_service.outputs.uri
    HR_SERVICE_URI                  = data.terraform_remote_state.hr_service.outputs.uri
    USER_MANAGEMENT_SERVICE_URI     = data.terraform_remote_state.user_management_service.outputs.uri
    INVENTORY_SERVICE_URI           = data.terraform_remote_state.inventory_service.outputs.uri
    FINANCE_SERVICE_URI             = data.terraform_remote_state.finance_service.outputs.uri
    REPORTING_SERVICE_URI           = data.terraform_remote_state.reporting_service.outputs.uri
  }
}
