#!/bin/bash

# This script will update the IP of the CPE based off a DNS query. You do not need the OCID for the CPE, just the name
# You will need dns utils and jq to run this script

# === CONFIG ===
DNS_CPE="Your.Domain.here"                                         	# Dynamic IP to resolve
COMPARTMENT_ID="ocid1.tenancy.oc1..blah"    					   	          # Your Compartment OCID aka TenancyID
CPE_NAME="CPE-NAME_HERE"              								              # Your CPE's Display Name
OCI_BIN="OCI-BIN-Directory"                        					        # Path to OCI CLI (use `which oci` to find)

# === RESOLVE CURRENT IP ===
resolved_ip=$(dig +short "$DNS_CPE" | tail -n1)

if [[ -z "$resolved_ip" ]]; then
    echo "❌ Failed to resolve IP for $DNS_CPE"
    exit 1
fi

# === GET EXISTING CPE INFO ===
cpe_info=$($OCI_BIN network cpe list --compartment-id "$COMPARTMENT_ID" \
    --query "data[?\"display-name\"=='$CPE_NAME'] | [0]" --raw-output)

cpe_id=$(echo "$cpe_info" | jq -r '.id')
current_ip=$(echo "$cpe_info" | jq -r '.["ip-address"]')

# === CHECK + UPDATE ===
if [[ "$resolved_ip" == "$current_ip" ]]; then
    echo "✅ IP unchanged ($resolved_ip) – no update needed."
    exit 0
else
    echo "🔄 Updating CPE ($CPE_NAME) IP from $current_ip → $resolved_ip"
    $OCI_BIN network cpe update --cpe-id "$cpe_id" --ip-address "$resolved_ip"
fi
