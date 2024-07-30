#!/bin/bash

# Function to set the expiration date of a virtual machine
set_az_virtual_machine_expired_date() {
    local VM_NAME=$1
    local LAB_NAME=$2
    local EXPIRED_UTC_DATE=$3

    # Validate parameters
    if [[ -z "$VM_NAME" ]]; then
        echo "Error: VM_NAME parameter is required."
        exit 1
    fi
    if [[ -z "$LAB_NAME" ]]; then
        echo "Error: LAB_NAME parameter is required."
        exit 1
    fi
    if [[ -z "$EXPIRED_UTC_DATE" ]]; then
        echo "Error: EXPIRED_UTC_DATE parameter is required."
        exit 1
    fi

    # Get information about the virtual machine
    TARGET_VM_INFO=$(az resource list --query "[?name=='$LAB_NAME/$VM_NAME' && type=='Microsoft.DevTestLab/labs/virtualMachines']" --output json)

    # If the VM is not found, throw an error
    if [[ -z "$TARGET_VM_INFO" || "$TARGET_VM_INFO" == "[]" ]]; then
        echo "Error: No VM named $VM_NAME found in lab $LAB_NAME."
        exit 1
    fi

    # Get the resource ID of the virtual machine
    RESOURCE_ID=$(echo $TARGET_VM_INFO | jq -r '.[0].id')

    # Get the properties of the virtual machine
    VM_PROPERTIES=$(az resource show --id $RESOURCE_ID --query properties --output json)

    # Set the expiration date
    UPDATED_VM_PROPERTIES=$(echo $VM_PROPERTIES | jq --arg date "$EXPIRED_UTC_DATE" '.expirationDate = $date')

    # Update the resource with the new expiration date
    az resource update --id $RESOURCE_ID --set properties="$(echo $UPDATED_VM_PROPERTIES | jq -c .)"

    echo "Successfully set VM '$LAB_NAME/$VM_NAME' to expire on UTC $EXPIRED_UTC_DATE"
}

# Ensure Azure CLI is installed and you are logged in
if ! command -v az &> /dev/null
then
    echo "Azure CLI not found. Please install it and log in."
    exit 1
fi

# Check if the user is already logged in
if ! az account show > /dev/null 2>&1; then
    echo "Logging in to Azure..."
    az login --use-device-code
else
    echo "Already logged in to Azure."
fi

# Ensure three arguments are provided
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <VM_NAME> <LAB_NAME> <EXPIRED_UTC_DATE>"
    echo "Sample: $0 vm-poc-noatum devlab-poc-noatum 2025-10-10"
    exit 1
fi

# Get command-line arguments
VM_NAME=$1
LAB_NAME=$2
EXPIRED_UTC_DATE=$3

# Call the function with the provided parameters
set_az_virtual_machine_expired_date "$VM_NAME" "$LAB_NAME" "$EXPIRED_UTC_DATE"