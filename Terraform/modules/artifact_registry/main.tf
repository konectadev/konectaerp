resource "google_artifact_registry_repository" "repo" {
  provider = google
  location = var.region
  repository_id = var.repository_id
  description = "Docker repository for project artifacts"
  format = "DOCKER"
}
