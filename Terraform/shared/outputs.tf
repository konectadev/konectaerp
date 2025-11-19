output "service_account_email" { value = module.service_account.email }
output "vpc_connector_name" { value = google_vpc_access_connector.serverless_connector.name }
output "repo_url" { value = module.artifact_repo.url }
output "REPO_URL" { value = module.artifact_repo.url }
output "RABBITMQ_URI" { value = module.rabbitmq.uri }
output "MAILHOG_URI" { value = module.mailhog.uri }
output "CONSUL_URI" { value = module.consul.uri }
output "project_id" {
  value = var.project_id
}
output "region" {
  value = var.region
}
