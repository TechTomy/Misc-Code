 <#
.SYNOPSIS
      #requires -RunAsAdministrator

      Script to remediate STIG ID WN10-CC-000190: Disable AutoPlay on all drives
      Sets registry value NoDriveTypeAutoRun to 0x000000ff (255)

.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000190

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000190.ps1 
#>


try {
    # Define registry path and value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer"
    $registryName = "NoDriveTypeAutoRun"
    $registryValue = 255  # 0x000000ff in decimal, disables AutoPlay on all drives

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully configured AutoPlay to be disabled on all drives."
    } else {
        throw "Failed to set 'NoDriveTypeAutoRun' to 255 (0x000000ff)."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000190: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000190 remediation completed successfully."
