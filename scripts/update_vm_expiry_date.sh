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
    TARGET_VM_INFO=$(az resource list --query "[?name=='$LAB_NAME/$VM_NAME' && type=='Microsoft.DevTestLab/labs/virtualMachines']" --output tsv)

    # If the VM is not found, throw an error
    if [[ -z "$TARGET_VM_INFO" ]]; then
        echo "Error: No VM named $VM_NAME found in lab $LAB_NAME."
        exit 1
    fi

    # Get the resource ID of the virtual machine
    RESOURCE_ID=$(echo $TARGET_VM_INFO | awk '{print $1}')

    # Get the properties of the virtual machine
    VM_PROPERTIES=$(az resource show --id $RESOURCE_ID --query properties)

    # Set the expiration date
    UPDATED_VM_PROPERTIES=$(echo $VM_PROPERTIES | jq --arg date "$EXPIRED_UTC_DATE" '.expirationDate = $date')

    # Update the resource with the new expiration date
    az resource update --id $RESOURCE_ID --set properties="$UPDATED_VM_PROPERTIES"

    echo "Successfully set VM '$LAB_NAME/$VM_NAME' to expire on UTC $EXPIRED_UTC_DATE"
}

# Log in to Azure
az login --use-device-code

# Set the VM name, lab name, and expiration date
VM_NAME="vm-poc-noatum"
LAB_NAME="devlab-poc-noatum"
EXPIRED_UTC_DATE="2025-10-10"

# Ensure parameters are provided and call the function
if [[ -z "$VM_NAME" || -z "$LAB_NAME" || -z "$EXPIRED_UTC_DATE" ]]; then
    echo "Error: VM_NAME, LAB_NAME, and EXPIRED_UTC_DATE parameters are required."
    exit 1
else
    set_az_virtual_machine_expired_date "$VM_NAME" "$LAB_NAME" "$EXPIRED_UTC_DATE"
fi
