 <#
.SYNOPSIS
    The PowerShell script remediates STIG ID WN10-SO-000255 by setting the Windows 10 UAC registry value 
    ConsentPromptBehaviorUser to 0, ensuring standard user elevation requests are automatically denied..

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000255

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-SO-000255.ps1 
#>

#requires -RunAsAdministrator

# Script to remediate STIG ID WN10-SO-000255: Set UAC to automatically deny elevation requests for standard users
# Sets registry value ConsentPromptBehaviorUser to 0

try {
    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $registryName = "ConsentPromptBehaviorUser"
    $registryValue = 0  # Automatically deny elevation requests

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully set 'ConsentPromptBehaviorUser' to 0 (Automatically deny elevation requests)."
    } else {
        throw "Failed to set 'ConsentPromptBehaviorUser' to 0."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-SO-000255: $_"
    exit 1
}

Write-Output "STIG WN10-SO-000255 remediation completed successfully."
