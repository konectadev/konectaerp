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
  name   = "erp-serverless-connector"
  region = var.region
  network = google_compute_network.erp_vpc.name
  ip_cidr_range = "10.8.1.0/28" # small block for connector
}

module "rabbitmq" {
  source = "../modules/cloud_run"

  service_name          = "rabbitmq"
  region                = var.region
  image                 = "rabbitmq:3.13-management"
  port                  = 15672
  service_account_email = var.service_account_email
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  environment_variables = {
    RABBITMQ_DEFAULT_USER = "guest"
    RABBITMQ_DEFAULT_PASS = "guest"
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
  service_account_email = var.service_account_email
  vpc_connector         = google_vpc_access_connector.serverless_connector.name
}

module "consul" {
  source = "../modules/cloud_run"

  service_name          = "consul"
  region                = var.region
  image                 = "hashicorp/consul:1.18"
  port                  = 8500
  auth                  = "private"
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  environment_variables = {}
  custom_args           = ["agent", "-server", "-bootstrap", "-ui", "-client=0.0.0.0"]
  min_instances         = 1
  max_instances         = 1
  service_account_email = var.service_account_email
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
  service_account_email = var.service_account_email
  vpc_connector         = google_vpc_access_connector.serverless_connector.name
  min_instances         = 1
  max_instances         = 1
  environment_variables = {
    SERVER_PORT = "8888"
    CONSUL_HOST = "consul"
    CONSUL_PORT = "8500"
  }
  depends_on = [
    module.consul
  ]
}



#  Locals for common configuration
# locals {
#   common_config = {
#     region                = var.region
#     project_id            = var.project_id
#     service_account_email = var.service_account_email
#     image_repository      = "${var.region}-docker.pkg.dev/${var.project_id}/${var.image_repository_name}"
#     min_instances         = var.min_instances
#     max_instances         = var.max_instances
#     vpc_connector         = var.vpc_connector
#   }

#   services = {
#     "api-gateway" = {
#       port    = 8080
#       auth    = "public"
#       ingress = "INGRESS_TRAFFIC_ALL"
#       by_req  = true
#       environment_variables = {
#         SPRING_APPLICATION_NAME      = "api-gateway"
#         SPRING_CLOUD_CONFIG_URI      = "http://config-server:8888"
#         SPRING_CLOUD_CONFIG_FAILFAST = "true"
#         CONSUL_HOST                  = "consul"
#         CONSUL_PORT                  = "8500"
#         AUTH_SERVICE_URI             = "http://authentication-service:7280"
#         HR_SERVICE_URI               = "http://hr-service:5005"
#         USER_MANAGEMENT_SERVICE_URI  = "http://user-management-service:5078"
#         INVENTORY_SERVICE_URI        = "http://inventory-service:5020"
#         FINANCE_SERVICE_URI          = "http://finance-service:5003"
#         REPORTING_SERVICE_URI        = "http://reporting-service:8085"
#       }
#     }

#     "authentication-service" = {
#       port    = 7280
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "authentication-service"
#         SPRING__APPLICATION__NAME       = "authentication-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/auth-sql-connection:latest"
#       #   JWT_SECRET           = "projects/${var.project_id}/secrets/jwt-secret:latest"
#       # }
#     }

#     "user-management-service" = {
#       port    = 5078
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "user-management-service"
#         SPRING__APPLICATION__NAME       = "user-management-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/user-mgmt-sql-connection:latest"
#       # }
#     }

#     "hr-service" = {
#       port    = 5005
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "hr-service"
#         SPRING__APPLICATION__NAME       = "hr-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/hr-sql-connection:latest"
#       # }
#     }

#     "finance-service" = {
#       port    = 5003
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "finance-service"
#         SPRING__APPLICATION__NAME       = "finance-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/finance-sql-connection:latest"
#       # }
#     }

#     "inventory-service" = {
#       port    = 5020
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "inventory-service"
#         SPRING__APPLICATION__NAME       = "inventory-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/inventory-sql-connection:latest"
#       # }
#     }

#     "reporting-service" = {
#       port    = 8085
#       auth    = "private"
#       ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
#       by_req  = true
#       environment_variables = {
#         ASPNETCORE_ENVIRONMENT          = "Production"
#         SERVICE_NAME                    = "reporting-service"
#         SPRING__APPLICATION__NAME       = "reporting-service"
#         SPRING__CLOUD__CONFIG__URI      = "http://config-server:8888"
#         SPRING__CLOUD__CONFIG__FAILFAST = "true"
#         Consul__Host                    = "http://consul:8500"
#       }
#       # secrets = {
#       #   SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/reporting-sql-connection:latest"
#       # }
#     }
#   }
# }

# # Service account for Cloud Run services
# resource "google_service_account" "cloud_run_sa" {
#   account_id   = "cloud-run-services"
#   display_name = "Cloud Run Services Service Account"
# }

# # IAM roles for the service account
# resource "google_project_iam_member" "cloud_run_invoker" {
#   for_each = toset([
#     "roles/run.invoker",
#     "roles/secretmanager.secretAccessor",
#     "roles/cloudsql.client"
#   ])

#   project = var.project_id
#   role    = each.key
#   member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
# }
