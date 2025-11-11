resource "google_sql_database_instance" "sqlserver" {
  name             = "erp-sqlserver"
  database_version = "SQLSERVER_2022_STANDARD"
  region           = var.region

  settings {
    tier = "db-custom-1-3840"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.erp_vpc.id
    }
  }
  deletion_protection = false
}


resource "google_sql_database" "auth_db" {
  name     = "Konecta_Auth"
  instance = google_sql_database_instance.sqlserver.name
}

resource "google_sql_database" "hr_db" {
  name     = "Konecta_Hr"
  instance = google_sql_database_instance.sqlserver.name
}

resource "google_sql_database" "inventory_db" {
  name     = "Konecta_Inventory"
  instance = google_sql_database_instance.sqlserver.name
}

resource "google_sql_database" "finance_db" {
  name     = "Konecta_Finance"
  instance = google_sql_database_instance.sqlserver.name
}

resource "google_sql_database" "user_mgmt_db" {
  name     = "Konecta_UserManagement"
  instance = google_sql_database_instance.sqlserver.name
}

resource "google_sql_user" "sa_user" {
  name     = "sa"
  instance = google_sql_database_instance.sqlserver.name
  password = "YourStrong!Passw0rd"
}


