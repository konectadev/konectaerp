output "url" { value = format("%s-docker.pkg.dev/%s/%s", var.region, var.project_id, google_artifact_registry_repository.repo.repository_id) }
