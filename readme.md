# Elastic Cloud Private Service Connect (PSC) Terraform Module

This Terraform module sets up Google Cloud Private Service Connect (PSC) infrastructure to enable private connectivity to Elastic Cloud deployments. It creates the necessary GCP networking components to establish a secure, private connection between your GCP resources and Elastic Cloud services.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Google Cloud Project                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                            VPC Network                                  │    │
│  │                         (elastic-psc-network)                           │    │
│  │                                                                         │    │
│  │  ┌───────────────────────────────────────────────────────────────────┐  │    │
│  │  │                          Subnet                                   │  │    │
│  │  │                    (elastic-psc-subnet)                           │  │    │
│  │  │                      10.0.1.0/24                                  │  │    │
│  │  │                                                                   │  │    │
│  │  │  ┌─────────────────┐              ┌─────────────────────────────┐  │  │    │
│  │  │  │ Private Service │              │    Compute Instance         │  │  │    │
│  │  │  │ Connect         │              │   (elastic-psc-client)      │  │  │    │
│  │  │  │ Endpoint        │              │                             │  │  │    │
│  │  │  │                 │              │  - Test scripts             │  │  │    │
│  │  │  │ IP: 10.0.1.x    │◄─────────────┤  - No external IP           │  │  │    │
│  │  │  │                 │              │  - SSH via IAP/Console      │  │  │    │
│  │  │  └─────────────────┘              └─────────────────────────────┘  │  │    │
│  │  │                                                                   │  │    │
│  │  └───────────────────────────────────────────────────────────────────┘  │    │
│  │                                                                         │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                        Private DNS Zone                                 │    │
│  │               psc.{region}.gcp.elastic-cloud.com                       │    │
│  │                                                                         │    │
│  │         *.psc.{region}.gcp.elastic-cloud.com → 10.0.1.x                │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                         Firewall Rules                                 │    │
│  │                                                                         │    │
│  │  - SSH Access (port 22)                                                │    │
│  │  - Internal traffic (all ports)                                        │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ Private Service Connect
                                        │ (Secure tunnel)
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Elastic Cloud                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    Service Attachment                                   │    │
│  │         projects/cloud-production-168820/regions/{region}/              │    │
│  │         serviceAttachments/proxy-psc-production-{region}-v1-attachment  │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                        │                                        │
│                                        ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                   Elasticsearch Clusters                               │    │
│  │                                                                         │    │
│  │  Accessible via:                                                       │    │
│  │  https://{cluster-id}.psc.{region}.gcp.elastic-cloud.com:9243          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

Traffic Flow:
1. DNS Query: *.psc.{region}.gcp.elastic-cloud.com → Private DNS Zone → PSC Endpoint IP
2. HTTPS Request: Client → PSC Endpoint → Service Attachment → Elastic Cloud
3. Response: Elastic Cloud → Service Attachment → PSC Endpoint → Client
```

## Components Created by This Terraform Module

### ✅ **GCP Resources Created**

1. **VPC Network** (`google_compute_network`)
   - Custom VPC with no auto-created subnetworks
   - Configurable name with fallback to `{resource_prefix}-network`

2. **Subnet** (`google_compute_subnetwork`)
   - Single subnet with configurable CIDR (default: `10.0.1.0/24`)
   - Regional subnet in the specified region

3. **Private Service Connect Endpoint** (`google_compute_forwarding_rule`)
   - Forwarding rule targeting Elastic Cloud's service attachment
   - Static internal IP address reservation
   - Region-specific service attachment URI mapping

4. **Private DNS Zone** (`google_dns_managed_zone`)
   - Private DNS zone for `psc.{region}.gcp.elastic-cloud.com`
   - Wildcard A record pointing to PSC endpoint IP
   - Restricted to the created VPC network

5. **Firewall Rules** (`google_compute_firewall`)
   - SSH access rule (port 22) with configurable source ranges
   - Internal traffic rule (all ports within subnet CIDR)

6. **Service Account** (`google_service_account`) *(Optional)*
   - Created only when `create_compute_instance = true`
   - Used by the test compute instance

7. **Compute Instance** (`google_compute_instance`) *(Optional)*
   - Test instance with no external IP address
   - Includes startup script with connectivity tests
   - Access via Cloud Console SSH or Identity-Aware Proxy

### ❌ **Components NOT Created (Manual Configuration Required)**

1. **Elastic Cloud Deployment**
   - You must create your Elasticsearch/Kibana deployment in Elastic Cloud
   - Must be in the same region as your GCP resources

2. **Traffic Filter in Elastic Cloud**
   - After Terraform deployment, you must manually create a Private Service Connect traffic filter
   - Use the `psc_connection_id` output value
   - Associate the traffic filter with your Elastic deployment

3. **External Connectivity**
   - No external IP addresses are created for compute instances
   - No NAT Gateway or Cloud Router for internet access
   - SSH access requires Cloud Console or Identity-Aware Proxy

## Supported Regions

The module supports the following GCP regions with pre-configured Elastic Cloud service attachments:

- **Asia Pacific**: `asia-east1`, `asia-northeast1`, `asia-northeast3`, `asia-south1`, `asia-southeast1`, `asia-southeast2`, `australia-southeast1`
- **Europe**: `europe-north1`, `europe-west1`, `europe-west2`, `europe-west3`, `europe-west4`, `europe-west9`
- **Middle East**: `me-west1`
- **North America**: `northamerica-northeast1`, `us-central1`, `us-east1`, `us-east4`, `us-west1`
- **South America**: `southamerica-east1`

## Quick Start

1. **Clone and Configure**
   ```bash
   # Copy the example configuration
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit terraform.tfvars with your values
   vim terraform.tfvars
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure Elastic Cloud** (Manual Step)
   - Go to Elastic Cloud Console → Traffic filters
   - Create new Private Service Connect filter
   - Use the `psc_connection_id` from Terraform outputs
   - Associate with your deployment

4. **Test Connection**
   ```bash
   # SSH to test instance (if created)
   gcloud compute ssh INSTANCE_NAME --zone=ZONE --tunnel-through-iap
   
   # Run connectivity test
   /home/test_elastic_connection.sh
   ```

## Configuration Variables

### Required Variables
```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"  # Must match Elastic Cloud region
zone       = "us-central1-a"
```

### Optional Variables
```hcl
# Resource naming
resource_prefix = "elastic-psc"
network_name    = ""  # Auto-generated if empty
subnet_name     = ""  # Auto-generated if empty

# Network configuration
subnet_cidr = "10.0.1.0/24"

# Compute instance (for testing)
create_compute_instance = true
machine_type           = "e2-micro"
boot_disk_size         = 100

# Security
ssh_source_ranges = ["0.0.0.0/0"]  # Restrict for production
```

## Outputs

Key outputs for completing the setup:

- `psc_connection_id`: Use this in Elastic Cloud traffic filter
- `psc_endpoint_ip`: Internal IP of the PSC endpoint
- `private_zone_dns_name`: DNS zone for connecting to Elastic
- `elastic_cloud_endpoint_pattern`: Connection URL pattern
- `next_steps`: Detailed instructions for completion

## Connection URL Format

Once configured, connect to your Elastic deployment using:
```
https://YOUR_ELASTICSEARCH_CLUSTER_ID.psc.{region}.gcp.elastic-cloud.com:9243
```

Replace `YOUR_ELASTICSEARCH_CLUSTER_ID` with your actual cluster ID from Elastic Cloud.

## Security Considerations

- **No External IPs**: Compute instances have no external IP addresses
- **Private Connectivity**: All traffic to Elastic Cloud flows through private PSC
- **Firewall Rules**: Only SSH and internal traffic are allowed
- **IAP Access**: Use Identity-Aware Proxy for secure SSH access
- **Restrict SSH**: Update `ssh_source_ranges` to limit SSH access

## Troubleshooting

### Common Issues

1. **Region Mismatch**: Ensure GCP region matches Elastic Cloud deployment region
2. **DNS Resolution**: Test with `nslookup` from within the VPC
3. **Traffic Filter**: Verify PSC traffic filter is created and associated in Elastic Cloud
4. **Connectivity**: Use the provided test script on the compute instance

### Test Commands
```bash
# Test DNS resolution
nslookup psc.{region}.gcp.elastic-cloud.com

# Test connectivity (expect 403 until traffic filter configured)
curl -v https://psc.{region}.gcp.elastic-cloud.com:9243

# Check PSC connection status
gcloud compute forwarding-rules describe PSC_ENDPOINT_NAME --region=REGION
```

## Cost Considerations

- **PSC Endpoint**: ~$0.01 per hour per endpoint
- **Compute Instance**: Based on machine type (e2-micro ~$5-7/month)
- **DNS Queries**: Minimal cost for private zones
- **Data Transfer**: No additional charges for PSC traffic

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: Manually remove the traffic filter from Elastic Cloud before destroying Terraform resources.

## License

This module is provided as-is for educational and operational purposes. Ensure compliance with your organization's policies and Elastic Cloud terms of service.