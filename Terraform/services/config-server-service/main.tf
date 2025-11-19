
data "terraform_remote_state" "shared" {
  backend = "gcs"
  config = {
    bucket = "konecta-erp-system"
    prefix = "shared"
  }
}


module "config_server" {
  source = "../../modules/cloud_run"

  service_name          = "config-server"
  project_id            = data.terraform_remote_state.shared.outputs.project_id
  region                = data.terraform_remote_state.shared.outputs.region
  image                 = "${var.repo_url}/config-server:${var.image_tag}"
  port                  = 8888
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  service_account_email = data.terraform_remote_state.shared.outputs.service_account_email
  vpc_connector         = data.terraform_remote_state.shared.outputs.vpc_connector_name

  min_instances = 1
  max_instances = 1

  environment_variables = {
    SERVER_PORT = "8888"
    CONSUL_HOST = "consul"
    CONSUL_PORT = "8500"
    # CONSUL_ENDPOINT = data.terraform_remote_state.shared.outputs.CONSUL_ENDPOINT
    CONSUL_URI = data.terraform_remote_state.shared.outputs.CONSUL_URI
  }
}
