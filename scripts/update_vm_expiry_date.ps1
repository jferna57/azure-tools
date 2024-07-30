# Import the Az module if not already imported
Import-Module Az -ErrorAction SilentlyContinue

Function Set-AzVirtualMachineExpiredDate {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)][String]$VMName,
        [Parameter(Mandatory=$true)][String]$LabName,
        [Parameter(Mandatory=$true)][DateTime]$ExpiredUTCDate
    )

    # Validate parameters
    if (-not $VMName) {
        Throw "Error: VMName parameter is required."
    }
    if (-not $LabName) {
        Throw "Error: LabName parameter is required."
    }
    if (-not $ExpiredUTCDate) {
        Throw "Error: ExpiredUTCDate parameter is required."
    }

    # Get information about the virtual machine
    $targetVMInfo = Get-AzResource | Where-Object { $_.Name -eq "$LabName/$VMName" -and $_.ResourceType -eq 'Microsoft.DevTestLab/labs/virtualMachines' }

    # If the VM is not found, throw an exception
    if ($targetVMInfo -eq $null) {
        Throw "Error: No VM named $VMName found in lab $LabName."
    }

    # Get the properties of the virtual machine
    $vmInfoWithProperties = Get-AzResource -ResourceId $targetVMInfo.ResourceId -ExpandProperties
    $vmProperties = $vmInfoWithProperties.Properties

    # Set the expiration date
    $vmProperties | Add-Member -MemberType NoteProperty -Name expirationDate -Value $ExpiredUTCDate -Force
    Set-AzResource -ResourceId $targetVMInfo.ResourceId -Properties $vmProperties -Force

    Write-Host "Successfully set VM '$LabName/$VMName' to expire on UTC $ExpiredUTCDate"
}

# 1. Log in to Azure
Connect-AzAccount -UseDeviceAuthentication

# 2. Set the VM name, lab name, and expiration date
$VMName = "vm-poc-noatum"
$LabName = "devlab-poc-noatum"
$ExpiredUTCDate = "2025-10-10"

# 3. Ensure parameters are provided and call the function
if (-not $VMName -or -not $LabName -or -not $ExpiredUTCDate) {
    Write-Host "Error: VMName, LabName, and ExpiredUTCDate parameters are required."
} else {
    Set-AzVirtualMachineExpiredDate -VMName $VMName -LabName $LabName -ExpiredUTCDate $ExpiredUTCDate
}
