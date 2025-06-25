 <#
.SYNOPSIS
   
    PowerShell script to check and configure Security event log size (STIG ID: WN10-AU-000505)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-24
    Last Modified   : 2025-06-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000505

.TESTED ON
    Date(s) Tested  : 2025-06-24
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-AU-000505.ps1 
#>

# Define variables
$STIG_ID = "WN10-AU-000505"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
$RegName = "MaxSize"
$RequiredValue = 1024000  # STIG requires 1024000 KB (0x000fa000) or greater

# Function to check if system sends audit records to an audit server
function Test-AuditServer {
    Write-Host "Does this system send audit records directly to an audit server? (Y/N)"
    Write-Host "Note: If yes, this must be documented with the ISSO."
    $Response = Read-Host
    if ($Response -eq 'Y' -or $Response -eq 'y') {
        Write-Host "STIG ID: $STIG_ID is Not Applicable (NA) for this system."
        return $true
    }
    return $false
}

# Function to check current registry setting
function Check-SecurityEventLogSize {
    try {
        # Check if the registry value exists
        $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $RegName
        if ($null -eq $CurrentValue) {
            Write-Host "Registry value '$RegName' does not exist."
            return $null
        }
        Write-Host "Current MaxSize value: $CurrentValue KB"
        return $CurrentValue
    } catch {
        Write-Host "Error: Could not retrieve registry value '$RegName'."
        return $null
    }
}

# Function to set registry value
function Set-SecurityEventLogSize {
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

# Check if system uses an audit server (NA condition)
if (Test-AuditServer) {
    exit
}

# Check current setting
$CurrentValue = Check-SecurityEventLogSize

if ($null -eq $CurrentValue) {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (Registry value missing). Configuring to $RequiredValue KB..."
    Set-SecurityEventLogSize -Value $RequiredValue
} elseif ($CurrentValue -ge $RequiredValue) {
    Write-Host "System is compliant with STIG ID: $STIG_ID (MaxSize: $CurrentValue KB)."
} else {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (MaxSize: $CurrentValue KB). Configuring to $RequiredValue KB..."
    Set-SecurityEventLogSize -Value $RequiredValue
}

# Verify the change
$NewValue = Check-SecurityEventLogSize
if ($NewValue -ge $RequiredValue) {
    Write-Host "Successfully configured MaxSize to $NewValue KB."
} elseif ($null -eq $NewValue) {
    Write-Host "Error: Registry value still missing after configuration attempt."
} else {
    Write-Host "Error: Failed to configure MaxSize (Current value: $NewValue KB)."
}
