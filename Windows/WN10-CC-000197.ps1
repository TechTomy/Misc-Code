<#
.SYNOPSIS
      
       #requires -RunAsAdministrator

      Script to remediate STIG ID WN10-CC-000197: Turn off Microsoft consumer experiences
      Sets registry value DisableWindowsConsumerFeatures to 1


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000197

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000197.ps1 
#>

try {
    # Check if system is Windows 10 v1507 LTSB (not applicable)
    $osVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    if ($osVersion -eq "1507") {
        Write-Output "Windows 10 v1507 LTSB detected. STIG WN10-CC-000197 is not applicable."
        exit 0
    }

    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryName = "DisableWindowsConsumerFeatures"
    $registryValue = 1  # Turn off Microsoft consumer experiences

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully turned off Microsoft consumer experiences."
    } else {
        throw "Failed to set 'DisableWindowsConsumerFeatures' to 1."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000197: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000197 remediation completed successfully." 
