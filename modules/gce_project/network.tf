resource "google_compute_network" "main" {
  name = "main"
  project = "${var.project}"
}

output "gce_network" {
  value = "${google_compute_network.main.name}"
}

resource "google_compute_subnetwork" "public" {
  name = "public"
  ip_cidr_range = "10.10.1.0/24"
  network = "${google_compute_network.main.self_link}"
  region = "us-central1"

  project = "${var.project}"
}

output "gce_subnetwork_public" {
  value = "${google_compute_subnetwork.public.name}"
}

resource "google_compute_subnetwork" "workers_org" {
  name = "workersorg"
  ip_cidr_range = "10.10.2.0/24"
  network = "${google_compute_network.main.self_link}"
  region = "us-central1"

  project = "${var.project}"
}

resource "google_compute_subnetwork" "workers_com" {
  name = "workerscom"
  ip_cidr_range = "10.10.3.0/24"
  network = "${google_compute_network.main.self_link}"
  region = "us-central1"

  project = "${var.project}"
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = "${google_compute_network.main.name}"
  source_ranges = ["0.0.0.0/0"]

  project = "${var.project}"

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name = "allow-ssh"
  network = "${google_compute_network.main.name}"
  source_ranges = ["0.0.0.0/0"]

  project = "${var.project}"

  allow {
    protocol = "tcp"
    ports = [22]
  }
}
