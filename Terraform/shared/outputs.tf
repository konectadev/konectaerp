output "region" {
  value = var.region
}

output "service_account_email" {
  value = google_service_account.service_account_module.email
}

output "vpc_connector" {
  value = google_vpc_access_connector.serverless_connector.name
}

# output "sql_connection_string" {
#   value = "Server=${google_sql_database_instance.sqlserver.connection_name};User Id=sa;Password=${var.sql_password};"
# }

output "sql_instance_connection_name" {
  value = google_sql_database_instance.sqlserver.connection_name
}

output "config_server_url" {
  value = module.config_server.url
}

output "rabbitmq_url" {
  value = module.rabbitmq.url
}

