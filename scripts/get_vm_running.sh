#!/bin/bash

# Ensure Azure CLI is installed and you are logged in
if ! command -v az &> /dev/null
then
    echo "Azure CLI not found. Please install it and log in."
    exit 1
fi

# Fetch the list of all running VMs and display their name and size
echo "Fetching the total number of running virtual machines, their names, and sizes..."

# Get the total number of running VMs
total_vms=$(az vm list --show-details --query "[?powerState=='VM running']" --output tsv | wc -l)
echo "Total number of running VMs: $total_vms"

# List the names and sizes of running VMs
az vm list --show-details --query "[?powerState=='VM running'].[name,hardwareProfile.vmSize]" --output table