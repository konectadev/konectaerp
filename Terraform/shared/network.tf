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

//Reserve peering IP range
resource "google_compute_global_address" "private_services_range" {
  name          = "private-services-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.erp_vpc.id
}

//Create service networking connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.erp_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_range.name]
}

resource "google_vpc_access_connector" "serverless_connector" {
  name          = "erp-serverless-connector"
  region        = var.region
  network       = google_compute_network.erp_vpc.name
  ip_cidr_range = "10.8.1.0/28" # small block for connector
  min_instances = 2
  max_instances = 3
}
