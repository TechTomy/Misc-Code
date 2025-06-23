<#
.SYNOPSIS
       #requires -RunAsAdministrator

      Script to remediate STIG ID WN10-SO-000167: Restrict remote SAM calls to Administrators
      Sets registry value RestrictRemoteSAM to O:BAG:BAD:(A;;RC;;;BA)


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000167

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-SO-000167.ps1 
#>

try {
    # Check if system is Windows 10 v1507 LTSB (not applicable)
    $osVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    if ($osVersion -eq "1507") {
        Write-Output "Windows 10 v1507 LTSB detected. STIG WN10-SO-000167 is not applicable."
        exit 0
    }

    # Define registry path and value
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $registryName = "RestrictRemoteSAM"
    $registryValue = "O:BAG:BAD:(A;;RC;;;BA)"  # Security descriptor allowing Administrators only

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type String -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully restricted remote SAM calls to Administrators."
    } else {
        throw "Failed to set 'RestrictRemoteSAM' to 'O:BAG:BAD:(A;;RC;;;BA)'."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-SO-000167: $_"
    exit 1
}

Write-Output "STIG WN10-SO-000167 remediation completed successfully." 
