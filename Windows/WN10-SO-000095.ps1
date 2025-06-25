 <#
.SYNOPSIS
   
    PowerShell script to check and configure Smart Card removal behavior (STIG ID: WN10-SO-000095)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-24
    Last Modified   : 2025-06-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         :  WN10-SO-000095 

.TESTED ON
    Date(s) Tested  : 2025-06-24
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\ WN10-SO-000095.ps1 
#>


# Define variables
$STIG_ID = "WN10-SO-000095"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$RegName = "SCRemoveOption"
$RequiredValue = "1"  # STIG requires "1" (Lock Workstation) or "2" (Force Logoff); default to "1"
$ValidValues = @("1", "2")  # Acceptable values per STIG

# Function to check if system meets NA conditions
function Test-NAConditions {
    Write-Host "Does this system meet any of the following conditions, documented with the ISSO? (Y/N)"
    Write-Host "- The setting cannot be configured due to mission needs or application interference."
    Write-Host "- Policy ensures users manually lock workstations when unattended."
    Write-Host "- Screen saver is configured to lock as required."
    $Response = Read-Host
    if ($Response -eq 'Y' -or $Response -eq 'y') {
        Write-Host "STIG ID: $STIG_ID is Not Applicable (NA) for this system."
        return $true
    }
    return $false
}

# Function to check current registry setting
function Check-SmartCardRemoval {
    try {
        # Check if the registry value exists
        $CurrentValue = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $RegName
        if ($null -eq $CurrentValue) {
            Write-Host "Registry value '$RegName' does not exist."
            return $null
        }
        Write-Host "Current SCRemoveOption value: $CurrentValue"
        return $CurrentValue
    } catch {
        Write-Host "Error: Could not retrieve registry value '$RegName'."
        return $null
    }
}

# Function to set registry value
function Set-SmartCardRemoval {
    param (
        [string]$Value
    )
    try {
        # Ensure registry path exists
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        # Set the registry value
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $Value -Type String -Force
        Write-Host "Set '$RegName' to $Value in $RegPath."
    } catch {
        Write-Host "Error: Failed to set registry value '$RegName'."
    }
}

# Main script logic
Write-Host "Checking STIG ID: $STIG_ID compliance..."

# Check if system meets NA conditions
if (Test-NAConditions) {
    exit
}

# Check current setting
$CurrentValue = Check-SmartCardRemoval

if ($null -eq $CurrentValue) {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (Registry value missing). Configuring to $RequiredValue..."
    Set-SmartCardRemoval -Value $RequiredValue
} elseif ($ValidValues -contains $CurrentValue) {
    Write-Host "System is compliant with STIG ID: $STIG_ID (SCRemoveOption: $CurrentValue)."
} else {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID (SCRemoveOption: $CurrentValue). Configuring to $RequiredValue..."
    Set-SmartCardRemoval -Value $RequiredValue
}

# Verify the change
$NewValue = Check-SmartCardRemoval
if ($ValidValues -contains $NewValue) {
    Write-Host "Successfully configured SCRemoveOption to $NewValue."
} elseif ($null -eq $NewValue) {
    Write-Host "Error: Registry value still missing after configuration attempt."
} else {
    Write-Host "Error: Failed to configure SCRemoveOption (Current value: $NewValue)."
}
