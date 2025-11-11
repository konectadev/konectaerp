data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp"
    prefix = "shared"
  }
}

module "authentication-service" {
  source = "../../modules/cloud_run"
  service_name = "authentication-service"
  region = data.terraform_remote_state.shared.outputs.region
  image = "${var.repo_url}/authentication-service:${var.image_tag}"
  port = 7280
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector = data.terraform_remote_state.shared.outputs.vpc_connector
  auth = "private"
  by_req = true
  min_instances = var.min_instances
  max_instances = var.max_instances
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  # sql_instance = google_sql_database_instance.sqlserver.connection_name

  environment_variables = {
    ASPNETCORE_ENVIRONMENT = "Production"
    SERVICE_NAME = "authentication-service"
    SPRING__APPLICATION__NAME = "authentication-service"
    SPRING__CLOUD__CONFIG__URI = "http://config-server:8888"
    SPRING__CLOUD__CONFIG__FAILFAST = "true"
    Consul__Host = "http://consul:8500"
  }
}