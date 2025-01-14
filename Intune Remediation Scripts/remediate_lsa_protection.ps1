<#
.DESCRIPTION
    Ensures the RunAsPPL registry key is set to 1. 
    Creates or updates the key and returns exit code 0 on success, 1 on failure.
	Author: emdeh
    Version: 2.0.0
#>

$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$name   = 'RunAsPPL'
$value  = 1

try {
    # Ensure the registry path exists
    if (-not (Test-Path $regKey)) {
        New-Item -Path $regKey -ErrorAction Stop | Out-Null
    }
}
catch {
    Write-Output "Error creating/accessing registry key: $_"
    exit 1
}

try {
    $currentValue = (Get-ItemProperty -Path $regKey -Name $name -ErrorAction SilentlyContinue).$name

    if ($null -eq $currentValue) {
        # Property doesn't exist, create it
        New-ItemProperty -Path $regKey -Name $name -Value $value -PropertyType DWORD -ErrorAction Stop | Out-Null
        Write-Output "Remediation succeeded: Created RunAsPPL=1."
        exit 0
    }
    else {
        # Property exists, update it
        Set-ItemProperty -Path $regKey -Name $name -Value $value -ErrorAction Stop
        Write-Output "Remediation succeeded: Updated RunAsPPL to 1."
        exit 0
    }
}
catch {
    Write-Output "Error setting RunAsPPL: $_"
    exit 1
}
