 <#
.SYNOPSIS
    #requires -RunAsAdministrator

    Script to remediate STIG ID WN10-SO-000080: Configure legal banner dialog box title
    Sets registry value LegalNoticeCaption to "DoD Notice and Consent Banner"

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-23
    Last Modified   : 2025-06-23
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000080

.TESTED ON
    Date(s) Tested  : 2025-06-23
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-SO-000080.ps1 
#>

try {
    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $registryName = "LegalNoticeCaption"
    $registryValue = "DoD Notice and Consent Banner"  # Standard DoD banner title

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type String -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully configured legal banner dialog box title to 'DoD Notice and Consent Banner'."
    } else {
        throw "Failed to set 'LegalNoticeCaption' to 'DoD Notice and Consent Banner'."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-SO-000080: $_"
    exit 1
}

Write-Output "STIG WN10-SO-000080 remediation completed successfully."
