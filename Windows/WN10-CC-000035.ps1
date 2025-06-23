<#
.SYNOPSIS
      
      #requires -RunAsAdministrator
      
      Script to remediate STIG ID WN10-CC-000035: Ignore NetBIOS name release requests except from WINS servers
      Sets registry value NoNameReleaseOnDemand to 1


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000035

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000035.ps1 
#>


try {
    # Define registry path and value
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters"
    $registryName = "NoNameReleaseOnDemand"
    $registryValue = 1  # Enable ignoring NetBIOS name release requests except from WINS servers

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry value
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWORD -Force

    # Verify the setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
    if ($currentValue.$registryName -eq $registryValue) {
        Write-Output "Successfully configured system to ignore NetBIOS name release requests except from WINS servers."
    } else {
        throw "Failed to set 'NoNameReleaseOnDemand' to 1."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000035: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000035 remediation completed successfully."
