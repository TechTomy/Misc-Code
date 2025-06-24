 <#
.SYNOPSIS
    #requires -RunAsAdministrator

    PowerShell script to check and configure BitLocker PIN for pre-boot authentication (STIG ID: WN10-00-000031)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-24
    Last Modified   : 2025-06-24
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-00-000031

.TESTED ON
    Date(s) Tested  : 2025-06-24
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-00-000031.ps1 
#>

# Define variables
$STIG_ID = "WN10-00-000031"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"
$Settings = @{
    "UseAdvancedStartup" = 1
    "UseTPMPIN"          = 1  # Set to 2 for BitLocker network unlock
    "UseTPMKeyPIN"       = 1  # Set to 2 for BitLocker network unlock
}

# Function to check if system is a VDI or AVD (requires manual input for simplicity)
function Test-VDIorAVD {
    Write-Host "Is this system a Virtual Desktop Implementation (VDI) where instances are deleted/refreshed upon logoff, or an Azure Virtual Desktop (AVD) with no data at rest? (Y/N)"
    $Response = Read-Host
    if ($Response -eq 'Y' -or $Response -eq 'y') {
        Write-Host "STIG ID: $STIG_ID is Not Applicable (NA) for this system."
        return $true
    }
    return $false
}

# Function to check registry settings
function Check-BitLockerSettings {
    $Compliance = $true
    $Results = @{}

    foreach ($Setting in $Settings.Keys) {
        try {
            $CurrentValue = Get-ItemProperty -Path $RegPath -Name $Setting -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Setting
            if ($null -eq $CurrentValue) {
                Write-Host "Registry value '$Setting' does not exist."
                $Results[$Setting] = $null
                $Compliance = $false
            } else {
                Write-Host "Current $Setting value: $CurrentValue"
                $Results[$Setting] = $CurrentValue
                if ($CurrentValue -ne $Settings[$Setting]) {
                    $Compliance = $false
                }
            }
        } catch {
            Write-Host "Error: Could not retrieve registry value '$Setting'."
            $Results[$Setting] = $null
            $Compliance = $false
        }
    }
    return @{ Compliance = $Compliance; Results = $Results }
}

# Function to set registry values
function Set-BitLockerSettings {
    try {
        # Ensure registry path exists
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        # Set each registry value
        foreach ($Setting in $Settings.Keys) {
            Set-ItemProperty -Path $RegPath -Name $Setting -Value $Settings[$Setting] -Type DWord -Force
            Write-Host "Set '$Setting' to $($Settings[$Setting]) in $RegPath."
        }
    } catch {
        Write-Host "Error: Failed to set registry values."
    }
}

# Main script logic
Write-Host "Checking STIG ID: $STIG_ID compliance..."

# Check if system is VDI or AVD
if (Test-VDIorAVD) {
    exit
}

# Check current settings
$CheckResult = Check-BitLockerSettings

if ($CheckResult.Compliance) {
    Write-Host "System is compliant with STIG ID: $STIG_ID."
} else {
    Write-Host "System is NOT compliant with STIG ID: $STIG_ID. Configuring required settings..."
    Set-BitLockerSettings
    # Verify changes
    $NewCheckResult = Check-BitLockerSettings
    if ($NewCheckResult.Compliance) {
        Write-Host "Successfully configured BitLocker settings for STIG ID: $STIG_ID."
    } else {
        Write-Host "Error: Failed to configure BitLocker settings."
        foreach ($Setting in $NewCheckResult.Results.Keys) {
            Write-Host "$Setting current value: $($NewCheckResult.Results[$Setting])"
        }
    }
} 
