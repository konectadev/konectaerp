resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region

  ingress = var.ingress
  launch_stage = "GA"

  template {
    containers {
      image = var.image

      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

       dynamic "env" {
      for_each = var.environment_variables
      content {
        name  = env.key
        value = env.value
        }
      }

      args = var.custom_args
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    service_account = var.service_account_email

    vpc_access {
      connector = var.vpc_connector
      egress    = var.vpc_egress
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.auth == "public" ? 1 : 0
  service  = google_cloud_run_v2_service.service.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "uri" {
  value = google_cloud_run_v2_service.service.uri
}
