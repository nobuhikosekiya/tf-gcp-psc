# Local variables for region-specific Elastic Cloud Service Attachments and computed names
locals {
  # Common tags to apply to all resources
  common_labels = var.common_labels
  # Resource names with fallbacks to prefixed defaults
  network_name         = var.network_name != "" ? var.network_name : "${var.resource_prefix}-network"
  subnet_name          = var.subnet_name != "" ? var.subnet_name : "${var.resource_prefix}-subnet"
  psc_endpoint_name    = var.psc_endpoint_name != "" ? var.psc_endpoint_name : "${var.resource_prefix}-endpoint"
  instance_name        = var.instance_name != "" ? var.instance_name : "${var.resource_prefix}-client-instance"
  service_account_name = var.service_account_name != "" ? var.service_account_name : "${var.resource_prefix}-client-sa"
  dns_zone_name        = var.dns_zone_name != "" ? var.dns_zone_name : "${var.resource_prefix}-${replace(var.region, "-", "")}-elastic-private-zone"

  # Map of regions to their Elastic Cloud Service Attachment URIs
  elastic_service_attachments = {
    "asia-east1"              = "projects/cloud-production-168820/regions/asia-east1/serviceAttachments/proxy-psc-production-asia-east1-v1-attachment"
    "asia-northeast1"         = "projects/cloud-production-168820/regions/asia-northeast1/serviceAttachments/proxy-psc-production-asia-northeast1-v1-attachment"
    "asia-northeast3"         = "projects/cloud-production-168820/regions/asia-northeast3/serviceAttachments/proxy-psc-production-asia-northeast3-v1-attachment"
    "asia-south1"             = "projects/cloud-production-168820/regions/asia-south1/serviceAttachments/proxy-psc-production-asia-south1-v1-attachment"
    "asia-southeast1"         = "projects/cloud-production-168820/regions/asia-southeast1/serviceAttachments/proxy-psc-production-asia-southeast1-v1-attachment"
    "asia-southeast2"         = "projects/cloud-production-168820/regions/asia-southeast2/serviceAttachments/proxy-psc-production-asia-southeast2-v1-attachment"
    "australia-southeast1"    = "projects/cloud-production-168820/regions/australia-southeast1/serviceAttachments/proxy-psc-production-australia-southeast1-v1-attachment"
    "europe-north1"           = "projects/cloud-production-168820/regions/europe-north1/serviceAttachments/proxy-psc-production-europe-north1-v1-attachment"
    "europe-west1"            = "projects/cloud-production-168820/regions/europe-west1/serviceAttachments/proxy-psc-production-europe-west1-v1-attachment"
    "europe-west2"            = "projects/cloud-production-168820/regions/europe-west2/serviceAttachments/proxy-psc-production-europe-west2-v1-attachment"
    "europe-west3"            = "projects/cloud-production-168820/regions/europe-west3/serviceAttachments/proxy-psc-production-europe-west3-v1-attachment"
    "europe-west4"            = "projects/cloud-production-168820/regions/europe-west4/serviceAttachments/proxy-psc-production-europe-west4-v1-attachment"
    "europe-west9"            = "projects/cloud-production-168820/regions/europe-west9/serviceAttachments/proxy-psc-production-europe-west9-v1-attachment"
    "me-west1"                = "projects/cloud-production-168820/regions/me-west1/serviceAttachments/proxy-psc-production-me-west1-v1-attachment"
    "northamerica-northeast1" = "projects/cloud-production-168820/regions/northamerica-northeast1/serviceAttachments/proxy-psc-production-northamerica-northeast1-v1-attachment"
    "southamerica-east1"      = "projects/cloud-production-168820/regions/southamerica-east1/serviceAttachments/proxy-psc-production-southamerica-east1-v1-attachment"
    "us-central1"             = "projects/cloud-production-168820/regions/us-central1/serviceAttachments/proxy-psc-production-us-central1-v1-attachment"
    "us-east1"                = "projects/cloud-production-168820/regions/us-east1/serviceAttachments/proxy-psc-production-us-east1-v1-attachment"
    "us-east4"                = "projects/cloud-production-168820/regions/us-east4/serviceAttachments/proxy-psc-production-us-east4-v1-attachment"
    "us-west1"                = "projects/cloud-production-168820/regions/us-west1/serviceAttachments/proxy-psc-production-us-west1-v1-attachment"
  }

  # Map of regions to their Private Zone DNS names
  elastic_private_zones = {
    "asia-east1"              = "psc.asia-east1.gcp.elastic-cloud.com"
    "asia-northeast1"         = "psc.asia-northeast1.gcp.cloud.es.io"
    "asia-northeast3"         = "psc.asia-northeast3.gcp.elastic-cloud.com"
    "asia-south1"             = "psc.asia-south1.gcp.elastic-cloud.com"
    "asia-southeast1"         = "psc.asia-southeast1.gcp.elastic-cloud.com"
    "asia-southeast2"         = "psc.asia-southeast2.gcp.elastic-cloud.com"
    "australia-southeast1"    = "psc.australia-southeast1.gcp.elastic-cloud.com"
    "europe-north1"           = "psc.europe-north1.gcp.elastic-cloud.com"
    "europe-west1"            = "psc.europe-west1.gcp.cloud.es.io"
    "europe-west2"            = "psc.europe-west2.gcp.elastic-cloud.com"
    "europe-west3"            = "psc.europe-west3.gcp.cloud.es.io"
    "europe-west4"            = "psc.europe-west4.gcp.elastic-cloud.com"
    "europe-west9"            = "psc.europe-west9.gcp.elastic-cloud.com"
    "me-west1"                = "psc.me-west1.gcp.elastic-cloud.com"
    "northamerica-northeast1" = "psc.northamerica-northeast1.gcp.elastic-cloud.com"
    "southamerica-east1"      = "psc.southamerica-east1.gcp.elastic-cloud.com"
    "us-central1"             = "psc.us-central1.gcp.cloud.es.io"
    "us-east1"                = "psc.us-east1.gcp.elastic-cloud.com"
    "us-east4"                = "psc.us-east4.gcp.elastic-cloud.com"
    "us-west1"                = "psc.us-west1.gcp.cloud.es.io"
  }

  service_attachment_uri = local.elastic_service_attachments[var.region]
  private_zone_dns_name  = local.elastic_private_zones[var.region]
}

# Create VPC Network
resource "google_compute_network" "elastic_network" {
  name                    = local.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create Subnet
resource "google_compute_subnetwork" "elastic_subnet" {
  name          = local.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.elastic_network.id
  project       = var.project_id
}

# Reserve static internal IP address for Private Service Connect endpoint
resource "google_compute_address" "psc_endpoint_ip" {
  name         = "${local.psc_endpoint_name}-ip"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.elastic_subnet.id
  region       = var.region
  project      = var.project_id

  labels = local.common_labels
}

# Create Private Service Connect endpoint
resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = local.psc_endpoint_name
  region                = var.region
  project               = var.project_id
  load_balancing_scheme = ""
  target                = local.service_attachment_uri
  network               = google_compute_network.elastic_network.id
  ip_address            = google_compute_address.psc_endpoint_ip.self_link

  labels = local.common_labels
}

# Create Private DNS Zone for Elastic Cloud
resource "google_dns_managed_zone" "elastic_private_zone" {
  name        = local.dns_zone_name
  dns_name    = "${local.private_zone_dns_name}."
  description = "Private DNS zone for Elastic Cloud Private Service Connect"
  project     = var.project_id

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.elastic_network.id
    }
  }

  labels = local.common_labels
}

# Create DNS A record pointing to the Private Service Connect endpoint
resource "google_dns_record_set" "elastic_wildcard_record" {
  name         = "*.${google_dns_managed_zone.elastic_private_zone.dns_name}"
  managed_zone = google_dns_managed_zone.elastic_private_zone.name
  type         = "A"
  ttl          = var.dns_ttl
  project      = var.project_id

  rrdatas = [google_compute_address.psc_endpoint_ip.address]
}

# Create firewall rule to allow SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.network_name}-allow-ssh"
  network = google_compute_network.elastic_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = [var.network_tags.ssh_access]
}

# Create firewall rule to allow internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.network_name}-allow-internal"
  network = google_compute_network.elastic_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

# Create service account for the compute instance
resource "google_service_account" "elastic_client_sa" {
  count        = var.create_compute_instance ? 1 : 0
  account_id   = local.service_account_name
  display_name = "Service Account for Elastic Client Instance"
  project      = var.project_id
}

# Create compute instance (conditional)
resource "google_compute_instance" "elastic_client" {
  count        = var.create_compute_instance ? 1 : 0
  name         = local.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = [var.network_tags.ssh_access, var.network_tags.elastic_client]

  labels = local.common_labels

  boot_disk {
    initialize_params {
      image  = var.os_image
      size   = var.boot_disk_size
      type   = var.disk_type
      labels = local.common_labels
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.elastic_subnet.id
    # No access_config block = no external IP
  }

  service_account {
    email  = google_service_account.elastic_client_sa[0].email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
    private_zone_dns_name = local.private_zone_dns_name
    psc_endpoint_ip       = google_compute_address.psc_endpoint_ip.address
    psc_connection_id     = google_compute_forwarding_rule.psc_endpoint.psc_connection_id
  })

  depends_on = [
    google_compute_forwarding_rule.psc_endpoint,
    google_dns_record_set.elastic_wildcard_record
  ]
}