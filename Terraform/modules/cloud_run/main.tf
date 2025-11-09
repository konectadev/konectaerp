resource "google_cloud_run_v2_service" "cloud_run_module" {
  name     = var.service_name
  location = var.region
  deletion_protection = false

  template {
    containers {
      image = var.image
      
      ports {
        container_port = var.port
      }

      resources {
        cpu_idle = var.by_req
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      # Dynamic environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Dynamic secrets
      dynamic "env" {
        for_each = var.secrets
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }

      startup_probe {
        initial_delay_seconds = 30
        timeout_seconds       = 240
        period_seconds        = 10
        failure_threshold     = 3
        tcp_socket {
          port = var.port
        }
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = var.port
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {
      connector = var.vpc_connector
      egress    = "ALL_TRAFFIC"
    }

    service_account = var.service_account_email
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = var.ingress
}

resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.auth == "public" ? 1 : 0
  service  = google_cloud_run_v2_service.cloud_run_module.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "internal_access" {
  count    = var.auth == "private" ? 1 : 0
  service  = google_cloud_run_v2_service.cloud_run_module.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account_email}"
}