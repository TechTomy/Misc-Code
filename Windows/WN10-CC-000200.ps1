<#
.SYNOPSIS
      #requires -RunAsAdministrator
      
      Script to remediate STIG ID WN10-CC-000200: Prevent enumeration of administrator accounts during elevation
      Sets registry value EnumerateAdministrators to 0


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000200

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000200.ps1 
#>

try {
    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI"
    $registryName = "EnumerateAdministrators"
    $registryValue = 0  # Disable enumeration of administrator accounts

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully disabled enumeration of administrator accounts during elevation."
    } else {
        throw "Failed to set 'EnumerateAdministrators' to 0."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000200: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000200 remediation completed successfully." 
