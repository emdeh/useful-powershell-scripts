<#
.DESCRIPTION
    Checks if the Transcription registry key is set to a specified DWORD value (1).
    Returns exit code 0 if compliant, 1 if non-compliant or any error.

    PowerShell Transcription captures the full command line input and output of PowerShell sessions, which can help detect abuse and support forensic investigations.
    
	Author: emdeh
    Version: 1.0.0
#>

$regKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription'
$name   = 'EnableTranscripting'
$value  = 1

try {
    if (-not (Test-Path $regKey)) {
        Write-Output "Non-compliant: Registry key does not exist."
        exit 1
    }

    $currentValue = (Get-ItemProperty -Path $regKey -Name $name -ErrorAction SilentlyContinue).$name

    if ($currentValue -eq $value) {
        Write-Output "Compliant: EnableTranscripting is set to 1."
        exit 0
    }
    else {
        Write-Output "Non-compliant: Found EnableTranscripting=$currentValue, expected 1."
        exit 1
    }
}
catch {
    Write-Output "Error checking EnableTranscripting: $_"
    exit 1
}