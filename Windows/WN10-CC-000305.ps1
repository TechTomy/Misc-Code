 <#
.SYNOPSIS
   
PowerShell script to check and configure indexing of encrypted files (STIG ID: WN10-CC-000305)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-24
    Last Modified   : 2025-06-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000305

.TESTED ON
    Date(s) Tested  : 2025-06-24
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000305.ps1 
#>

# Define variables
$STIG_ID = "WN10-CC-000305"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$RegName = "AllowIndexingEncryptedStoresOrItems"
$RequiredValue = 0  # STIG requires 0 to disable indexing of encrypted files

# Function to check current registry setting
function Check-IndexingEncryptedFiles {
    try {
        # Check if the registry value exists
        $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $RegName
        if ($null -eq $CurrentValue) {
            Write-Host "Registry value '$RegName' does not exist."
            return $null
        }
        Write-Host "Current AllowIndexingEncryptedStoresOrItems value: $CurrentValue"
        return $CurrentValue
    } catch {
        Write-Host "Error: Could not retrieve registry value '$RegName'."
        return $null
    }
}

# Function to set registry value
function Set-IndexingEncryptedFiles {
    param (
        [int]$Value
    )
    try {
        # Ensure registry path exists
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        # Set the registry value
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $Value -Type DWord -Force
        Write-Host "Set '$RegName' to $Value in $RegPath."
    } catch {
        Write-Host "Error: Failed to set registry value '$RegName'."
    }
}

# Main script logic
Write-Host "Checking STIG ID: $STIG_ID compliance..."
$CurrentValue = Check-IndexingEncryptedFiles

if ($null -eq $CurrentValue) {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (Registry value missing). Configuring to $RequiredValue..."
    Set-IndexingEncryptedFiles -Value $RequiredValue
} elseif ($CurrentValue -eq $RequiredValue) {
    Write-Host "System is compliant with STIG ID: $STIG_ID (AllowIndexingEncryptedStoresOrItems: $CurrentValue)."
} else {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (AllowIndexingEncryptedStoresOrItems: $CurrentValue). Configuring to $RequiredValue..."
    Set-IndexingEncryptedFiles -Value $RequiredValue
}

# Verify the change
$NewValue = Check-IndexingEncryptedFiles
if ($NewValue -eq $RequiredValue) {
    Write-Host "Successfully configured AllowIndexingEncryptedStoresOrItems to $RequiredValue."
} elseif ($null -eq $NewValue) {
    Write-Host "Error: Registry value still missing after configuration attempt."
} else {
    Write-Host "Error: Failed to configure AllowIndexingEncryptedStoresOrItems (Current value: $NewValue)."
}
