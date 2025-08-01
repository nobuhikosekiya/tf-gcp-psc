# Project and Region Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region (must match your Elastic Cloud deployment region)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone for the compute instance"
  type        = string
  default     = "us-central1-a"
}

# Resource Naming Variables
variable "resource_prefix" {
  description = "Common prefix for all resource names"
  type        = string
  default     = "elastic-psc"
}

variable "network_name" {
  description = "Name of the VPC network (will be prefixed with resource_prefix if not provided)"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Name of the subnet (will be prefixed with resource_prefix if not provided)"
  type        = string
  default     = ""
}

variable "psc_endpoint_name" {
  description = "Name of the PSC endpoint (will be prefixed with resource_prefix if not provided)"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name of the compute instance (will be prefixed with resource_prefix if not provided)"
  type        = string
  default     = ""
}

variable "service_account_name" {
  description = "Name of the service account (will be prefixed with resource_prefix if not provided)"
  type        = string
  default     = ""
}

variable "dns_zone_name" {
  description = "Name of the private DNS zone (will be auto-generated if not provided)"
  type        = string
  default     = ""
}

# Network Configuration
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Compute Instance Configuration
variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Type of disk (pd-standard, pd-ssd, pd-balanced)"
  type        = string
  default     = "pd-standard"
}

variable "os_image" {
  description = "OS image for the compute instance"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "create_compute_instance" {
  description = "Whether to create a compute instance for testing"
  type        = bool
  default     = true
}

# DNS Configuration
variable "dns_ttl" {
  description = "TTL for DNS records in seconds"
  type        = number
  default     = 300
}

# Firewall Configuration
variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "network_tags" {
  description = "Network tags for the compute instance"
  type        = object({
    ssh_access     = string
    elastic_client = string
  })
  default = {
    ssh_access     = "ssh-access"
    elastic_client = "elastic-client"
  }
}

variable "common_labels" {
  description = "common labels to apply to resources"
  type        = map(string)
  default     = {}
}