<#
.DESCRIPTION
    Checks if the Transcription registry key is set to specified values.
    Returns exit code 0 if compliant, 1 if non-compliant or any error.

    Consider using Intune Configuration settings or Intune to set Transcription Logging.

    PowerShell Transcription captures the full command line input and output of PowerShell sessions, which can help detect abuse and support forensic investigations.
    
    Author: emdeh
    Version: 1.0.0
#>

$regKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription'
$transcriptionSettings = @{
    EnableTranscripting = 1
    OutputDirectory = 'C:\Logs\PowerShellTranscripts'
    EnableInvocationHeader = 1
}

try {
    if (-not (Test-Path $regKey)) {
        Write-Output "Non-compliant: Registry key does not exist."
        exit 1
    }

    $currentValues = Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue

    foreach ($setting in $transcriptionSettings.GetEnumerator()) {
        $name = $setting.Key
        $expectedValue = $setting.Value
        $currentValue = $currentValues.$name

        if ($currentValue -ne $expectedValue) {
            Write-Output "Non-compliant: Found $name=$currentValue, expected $expectedValue."
            exit 1
        }
    }

    Write-Output "Compliant: All settings are correctly configured."
    exit 0
}
catch {
    Write-Output "Error checking transcription settings: $_"
    exit 1
}