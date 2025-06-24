 <#
.SYNOPSIS
   
    PowerShell script to check and configure SMB client packet signing (STIG ID: WN10-SO-000100)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-24
    Last Modified   : 2025-06-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000100

.TESTED ON
    Date(s) Tested  : 2025-06-24
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-SO-000100.ps1 
#>

# Define variables
$STIG_ID = "WN10-SO-000100"
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$RegName = "RequireSecuritySignature"
$RequiredValue = 1  # STIG requires 1 to enforce SMB packet signing

# Function to check current registry setting
function Check-SMBPacketSigning {
    try {
        # Check if the registry value exists
        $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $RegName
        if ($null -eq $CurrentValue) {
            Write-Host "Registry value '$RegName' does not exist."
            return $null
        }
        Write-Host "Current RequireSecuritySignature value: $CurrentValue"
        return $CurrentValue
    } catch {
        Write-Host "Error: Could not retrieve registry value '$RegName'."
        return $null
    }
}

# Function to set registry value
function Set-SMBPacketSigning {
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
$CurrentValue = Check-SMBPacketSigning

if ($null -eq $CurrentValue) {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (Registry value missing). Configuring to $RequiredValue..."
    Set-SMBPacketSigning -Value $RequiredValue
} elseif ($CurrentValue -eq $RequiredValue) {
    Write-Host "System is compliant with STIG ID: $STIG_ID (RequireSecuritySignature: $CurrentValue)."
} else {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (RequireSecuritySignature: $CurrentValue). Configuring to $RequiredValue..."
    Set-SMBPacketSigning -Value $RequiredValue
}

# Verify the change
$NewValue = Check-SMBPacketSigning
if ($NewValue -eq $RequiredValue) {
    Write-Host "Successfully configured RequireSecuritySignature to $RequiredValue."
} elseif ($null -eq $NewValue) {
    Write-Host "Error: Registry value still missing after configuration attempt."
} else {
    Write-Host "Error: Failed to configure RequireSecuritySignature (Current value: $NewValue)."
}
