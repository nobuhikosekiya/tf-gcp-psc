#!/bin/bash

# Update system packages
apt-get update
apt-get install -y curl dnsutils

# Create a test script to verify connectivity to Elastic Cloud
cat > /home/test_elastic_connection.sh << 'EOL'
#!/bin/bash
echo "=== Elastic Cloud Private Service Connect Connection Test ==="
echo "Date: $(date)"
echo ""

echo "Testing DNS resolution for Elastic Cloud..."
nslookup ${private_zone_dns_name}
echo ""

echo "Testing connectivity to Private Service Connect endpoint..."
echo "Attempting to connect to https://${private_zone_dns_name}:9243"
curl -v -k https://${private_zone_dns_name}:9243 2>&1 | head -20
echo ""

echo "=== Connection Information ==="
echo "Private Service Connect endpoint IP: ${psc_endpoint_ip}"
echo "PSC Connection ID: ${psc_connection_id}"
echo "Private DNS Zone: ${private_zone_dns_name}"
echo ""

echo "=== Expected Behavior ==="
echo "- DNS resolution should return: ${psc_endpoint_ip}"
echo "- HTTPS connection should return: 403 Forbidden (normal until traffic filter is configured)"
echo ""

echo "=== Next Steps ==="
echo "1. Create a Private Service Connect traffic filter in Elastic Cloud UI"
echo "2. Use PSC Connection ID: ${psc_connection_id}"
echo "3. Associate the traffic filter with your deployment"
echo ""

echo "=== Connection URL Pattern ==="
echo "To connect to your Elastic deployment, use:"
echo "https://YOUR_ELASTICSEARCH_CLUSTER_ID.${private_zone_dns_name}:9243"
echo ""

echo "=== Test completed at $(date) ==="
EOL

# Make the script executable and set proper ownership
chmod +x /home/test_elastic_connection.sh

# Try to set ownership to the default user (handle case where no user is logged in)
if [ -n "$(logname 2>/dev/null)" ]; then
    chown $(logname):$(logname) /home/test_elastic_connection.sh
else
    # Fallback: try common user names or leave as root
    for user in debian ubuntu admin; do
        if id "$user" &>/dev/null; then
            chown $user:$user /home/test_elastic_connection.sh
            break
        fi
    done
fi

# Create a simple info file with connection details
cat > /home/psc_connection_info.txt << EOL
Elastic Cloud Private Service Connect Information
===============================================

PSC Connection ID: ${psc_connection_id}
PSC Endpoint IP: ${psc_endpoint_ip}
Private DNS Zone: ${private_zone_dns_name}

Connection URL Pattern:
https://YOUR_ELASTICSEARCH_CLUSTER_ID.${private_zone_dns_name}:9243

To test the connection, run:
/home/test_elastic_connection.sh

Generated on: $(date)
EOL

echo "Setup completed. Test script available at /home/test_elastic_connection.sh"