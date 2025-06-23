<#
.SYNOPSIS
        #requires -RunAsAdministrator

        Script to remediate STIG ID WN10-CC-000327: Enable PowerShell Transcription
        Sets registry value EnableTranscripting to 1 and configures a secure transcript output directory


.NOTES
    Author          : Tomy Boboy
    LinkedIn        : linkedin.com/in/tomyboboy/
    GitHub          : github.com/TechTomy
    Date Created    : 2025-06-22
    Last Modified   : 2025-06-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000327

.TESTED ON
    Date(s) Tested  : 2025-06-22
    Tested By       : Tomy Boboy
    Systems Tested  : Windows 10 Pro - 10.0.19045 N/A Build 19045

.USAGE
    PS C:\> .\WN10-CC-000327.ps1 
#>

try {
    # Define registry path and values
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
    $enableTranscriptName = "EnableTranscripting"
    $enableTranscriptValue = 1  # Enable PowerShell Transcription
    $outputDirectoryName = "OutputDirectory"
    $outputDirectoryValue = "C:\PowerShellTranscripts"  # Secure directory for transcripts

    # Check if registry path exists, create if it doesn't
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set EnableTranscripting registry value
    Set-ItemProperty -Path $registryPath -Name $enableTranscriptName -Value $enableTranscriptValue -Type DWORD -Force

    # Set OutputDirectory registry value
    Set-ItemProperty -Path $registryPath -Name $outputDirectoryName -Value $outputDirectoryValue -Type String -Force

    # Create the transcript output directory if it doesn't exist
    if (-not (Test-Path $outputDirectoryValue)) {
        New-Item -Path $outputDirectoryValue -ItemType Directory -Force | Out-Null
    }

    # Secure the transcript directory: Remove non-admin access
    $acl = Get-Acl -Path $outputDirectoryValue
    $acl.SetAccessRuleProtection($true, $false)  # Disable inheritance, remove existing rules
    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($adminRule)
    $acl.SetAccessRule($systemRule)
    Set-Acl -Path $outputDirectoryValue -AclObject $acl

    # Verify the EnableTranscripting setting
    $currentValue = Get-ItemProperty -Path $registryPath -Name $enableTranscriptName -ErrorAction SilentlyContinue
    if ($currentValue.$enableTranscriptName -eq $enableTranscriptValue) {
        Write-Output "Successfully enabled PowerShell Transcription."
    } else {
        throw "Failed to set 'EnableTranscripting' to 1."
    }

    # Verify the OutputDirectory setting
    $currentOutputDir = Get-ItemProperty -Path $registryPath -Name $outputDirectoryName -ErrorAction SilentlyContinue
    if ($currentOutputDir.$outputDirectoryName -eq $outputDirectoryValue) {
        Write-Output "Successfully configured PowerShell transcript output directory to '$outputDirectoryValue'."
    } else {
        throw "Failed to set 'OutputDirectory' to '$outputDirectoryValue'."
    }

} catch {
    Write-Error "An error occurred while remediating STIG WN10-CC-000327: $_"
    exit 1
}

Write-Output "STIG WN10-CC-000327 remediation completed successfully." 
