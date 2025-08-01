# PSC Connection Outputs
output "psc_connection_id" {
  description = "Private Service Connect Connection ID (needed for Elastic Cloud traffic filter configuration)"
  value       = google_compute_forwarding_rule.psc_endpoint.psc_connection_id
}

output "psc_endpoint_ip" {
  description = "Private Service Connect endpoint IP address"
  value       = google_compute_address.psc_endpoint_ip.address
}

output "private_zone_dns_name" {
  description = "Private DNS zone name for Elastic Cloud"
  value       = local.private_zone_dns_name
}

output "service_attachment_uri" {
  description = "Elastic Cloud Service Attachment URI for the region"
  value       = local.service_attachment_uri
}

# Network Outputs
output "network_name" {
  description = "Name of the created VPC network"
  value       = google_compute_network.elastic_network.name
}

output "network_id" {
  description = "ID of the created VPC network"
  value       = google_compute_network.elastic_network.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = google_compute_subnetwork.elastic_subnet.name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = google_compute_subnetwork.elastic_subnet.id
}

# DNS Outputs
output "dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = google_dns_managed_zone.elastic_private_zone.name
}

output "dns_zone_id" {
  description = "ID of the private DNS zone"
  value       = google_dns_managed_zone.elastic_private_zone.id
}

# Compute Instance Outputs (conditional)
output "compute_instance_name" {
  description = "Name of the created compute instance"
  value       = var.create_compute_instance ? google_compute_instance.elastic_client[0].name : null
}

output "compute_instance_internal_ip" {
  description = "Internal IP address of the compute instance"
  value       = var.create_compute_instance ? google_compute_instance.elastic_client[0].network_interface[0].network_ip : null
}

output "compute_instance_zone" {
  description = "Zone of the compute instance"
  value       = var.create_compute_instance ? google_compute_instance.elastic_client[0].zone : null
}

output "service_account_email" {
  description = "Email of the service account used by the compute instance"
  value       = var.create_compute_instance ? google_service_account.elastic_client_sa[0].email : null
}

# Connection Information
output "elastic_cloud_endpoint_pattern" {
  description = "Pattern for connecting to Elastic Cloud deployments"
  value       = "https://YOUR_ELASTICSEARCH_CLUSTER_ID.${local.private_zone_dns_name}:9243"
}

# Next Steps Output
output "next_steps" {
  description = "Instructions for completing the setup"
  value = var.create_compute_instance ? join("", [
    "Next steps to complete the Private Service Connect setup:\n\n",
    "1. In Elastic Cloud UI:\n",
    "   - Go to Traffic filters\n",
    "   - Create a new Private Service Connect filter\n",
    "   - Use PSC Connection ID: ${google_compute_forwarding_rule.psc_endpoint.psc_connection_id}\n",
    "   - Associate the filter with your deployment\n\n",
    "2. Test the connection from the compute instance (SSH via Cloud Console or IAP):\n",
    "   - gcloud compute ssh ${google_compute_instance.elastic_client[0].name} --zone=${var.zone} --tunnel-through-iap\n",
    "   - Run: /home/test_elastic_connection.sh\n\n",
    "3. Connect to your Elastic deployment using:\n",
    "   https://YOUR_ELASTICSEARCH_CLUSTER_ID.${local.private_zone_dns_name}:9243\n\n",
    "Note: Instance has no external IP - use Cloud Console SSH or Identity-Aware Proxy for access."
  ]) : join("", [
    "Next steps to complete the Private Service Connect setup:\n\n",
    "1. In Elastic Cloud UI:\n",
    "   - Go to Traffic filters\n",
    "   - Create a new Private Service Connect filter\n",
    "   - Use PSC Connection ID: ${google_compute_forwarding_rule.psc_endpoint.psc_connection_id}\n",
    "   - Associate the filter with your deployment\n\n",
    "2. Connect to your Elastic deployment from resources in the VPC using:\n",
    "   https://YOUR_ELASTICSEARCH_CLUSTER_ID.${local.private_zone_dns_name}:9243\n\n",
    "Note: No compute instance was created. Connect from existing resources in the VPC."
  ])
}