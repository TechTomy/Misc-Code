 <#
.SYNOPSIS
       #requires -RunAsAdministrator

      Script to remediate STIG ID WN10-CC-000275: Prevent local drive sharing with Remote Desktop Session Hosts
      Sets registry value fDisableCdm to 1


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000275

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000275.ps1 
#>

try {
    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
    $registryName = "fDisableCdm"
    $registryValue = 1  # Disable drive redirection

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully disabled local drive sharing for Remote Desktop Session Hosts."
    } else {
        throw "Failed to set 'fDisableCdm' to 1."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000275: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000275 remediation completed successfully." 
