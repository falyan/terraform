provider "google" {
  credentials = file("/Users/palyan/Documents/TERRAFORM/CRED/rational-iris-436104-f3-fb1e5bdab7eb.json")
  project     = "rational-iris-436104-f3"
  region      = "asia-southeast2"
}

resource "google_compute_network" "custom_network" {
  name                    = "vpc-gke"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "vpc-subnet-gke"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-southeast2"
  network       = google_compute_network.custom_network.self_link
}

resource "google_container_cluster" "gke_cluster" {
  name     = "palyan-gke-cluster"
  location = "asia-southeast2-a" # Lokasi default cluster

  network    = google_compute_network.custom_network.self_link
  subnetwork = google_compute_subnetwork.subnet1.name
  remove_default_node_pool = false
  deletion_protection = false
  initial_node_count = 2
  min_master_version = "1.28"

  # Konfigurasi logging dan monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

resource "google_container_node_pool" "node_pool-1" {
  name       = "node-pool-1"
  cluster    = google_container_cluster.gke_cluster.name
  location   = "asia-southeast2-a"

  node_config {
    machine_type = "custom-2-4096"
    image_type   = "COS_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }
}
