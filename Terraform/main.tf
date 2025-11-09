#  Locals for common configuration
locals {
  common_config = {
    region               = var.region
    project_id           = var.project_id
    service_account_email = var.service_account_email
    image_repository     = "${var.region}-docker.pkg.dev/${var.project_id}/erp/${var.image_repository_name}"
    min_instances        = var.min_instances
    max_instances        = var.max_instances
    vpc_connector        = var.vpc_connector
  }

  services = {
    "api-gateway" = {
      port        = 8080
      auth        = "public"
      ingress     = "INGRESS_TRAFFIC_ALL"
      by_req      = true
      environment_variables = {
        SPRING_PROFILES_ACTIVE = "production"
        CONSUL_HOST            = var.consul_host
        CONSUL_PORT            = "8500"
      }
    }

    "authentication-service" = {
      port        = 7280
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "authentication-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/auth-sql-connection:latest"
        JWT_SECRET           = "projects/${var.project_id}/secrets/jwt-secret:latest"
      }
    }

    "user-management-service" = {
      port        = 5078
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "user-management-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/user-mgmt-sql-connection:latest"
      }
    }

    "hr-service" = {
      port        = 5005
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "hr-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/hr-sql-connection:latest"
      }
    }

    "finance-service" = {
      port        = 5003
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "finance-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/finance-sql-connection:latest"
      }
    }

    "inventory-service" = {
      port        = 5020
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "inventory-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/inventory-sql-connection:latest"
      }
    }

    "reporting-service" = {
      port        = 8085
      auth        = "private"
      ingress     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
      by_req      = true
      environment_variables = {
        ASPNETCORE_ENVIRONMENT = "Production"
        SERVICE_NAME           = "reporting-service"
        CONSUL_HOST            = var.consul_host
      }
      secrets = {
        SQL_CONNECTION_STRING = "projects/${var.project_id}/secrets/reporting-sql-connection:latest"
      }
    }
  }
}

# Deploy all services using the module
resource "module" "cloud_run_services" {
  for_each = local.services

  source = "./modules/cloud_run"

  service_name          = each.key
  region               = local.common_config.region
  image                = "${local.common_config.image_repository}/${each.key}:${var.image_tag}"
  port                 = each.value.port
  service_account_email = local.common_config.service_account_email
  auth                 = each.value.auth
  by_req               = each.value.by_req
  min_instances        = local.common_config.min_instances
  max_instances        = local.common_config.max_instances
  ingress              = each.value.ingress
  vpc_connector        = local.common_config.vpc_connector
  environment_variables = each.value.environment_variables
  secrets              = try(each.value.secrets, {})
}

# Cloud SQL Instance (if needed)
resource "google_sql_database_instance" "sql_server" {
  name             = "erp-sqlserver"
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region

  settings {
    tier = "db-custom-2-4096"
    
    ip_configuration {
      ipv4_enabled = false
      private_network = var.vpc_network
    }
  }

  deletion_protection = false
}

# Create databases for each service
resource "google_sql_database" "service_databases" {
  for_each = toset([
    "AuthenticationDB",
    "UserManagementDB", 
    "HRDB",
    "FinanceDB",
    "InventoryDB",
    "ReportingDB"
  ])

  name     = each.key
  instance = google_sql_database_instance.sql_server.name
}

# Service account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-services"
  display_name = "Cloud Run Services Service Account"
}

# IAM roles for the service account
resource "google_project_iam_member" "cloud_run_invoker" {
  for_each = toset([
    "roles/run.invoker",
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}