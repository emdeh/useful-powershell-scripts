<#
.DESCRIPTION
    Ensures the Transcription registry key is set to specified values.
    Creates or updates the keys and returns exit code 0 on success, 1 on failure.

    PowerShell Transcription captures the full command line input and output of PowerShell sessions, which can help detect abuse and support forensic investigations.
    
    This script alone is not enough. You should also consider setting file system auditing (Local Security Policy > Advanced Audit Policy Configuration > Object Access > Audit File System) and apply appropriate file system controls on the outputDirectory folder.

    See additional scripting at set_outputdir_acl.ps1

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
    # Ensure the registry path exists.
    if (-not (Test-Path $regKey)) {
        # If not, create it.
        New-Item -Path $regKey -ErrorAction Stop | Out-Null
    }
}
catch {
    # If can't create it, error out with exit code 1.
    Write-Output "Error creating/accessing registry key: $_"
    exit 1
}

try {
    # Load the current key values into $currentValues
    $currentValues = Get-ItemProperty -Path $regKey -ErrorAction SilentlyContinue

    # For each setting, enumerate the name and value and load them into $name and $setting.
    foreach ($setting in $transcriptionSettings.GetEnumerator()) {
        $name = $setting.Key
        $expectedValue = $setting.Value
        $currentValue = $currentValues.$name

        if ($null -eq $currentValue) {
            # Property doesn't exist, create it
            New-ItemProperty -Path $regKey -Name $name -Value $expectedValue -PropertyType (if ($name -eq 'OutputDirectory') { 'String' } else { 'DWORD' }) -ErrorAction Stop | Out-Null
            Write-Output "Remediation succeeded: Created $name=$expectedValue."
        }
        elseif ($currentValue -ne $expectedValue) {
            # Property exists, update it
            Set-ItemProperty -Path $regKey -Name $name -Value $expectedValue -ErrorAction Stop
            Write-Output "Remediation succeeded: Updated $name to $expectedValue."
        }
    }

    Write-Output "Remediation succeeded: All settings are correctly configured."
    exit 0
}
catch {
    Write-Output "Error setting transcription settings: $_"
    exit 1
}