<#
.DESCRIPTION
    Checks if the RunAsPPL registry key is set to a specified DWORD value (1).
    Returns exit code 0 if compliant, 1 if non-compliant or any error.
	Author: emdeh
    Version: 2.0.0
#>

$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$name   = 'RunAsPPL'
$value  = 1

try {
    if (-not (Test-Path $regKey)) {
        Write-Output 'Non-compliant: Registry key does not exist.'
        exit 1
    }

    $currentValue = (Get-ItemProperty -Path $regKey -Name $name -ErrorAction SilentlyContinue).$name
    
    if ($currentValue -eq $value) {
        Write-Output 'Compliant: RunAsPPL is set to 1.'
        exit 0
    }
    else {
        Write-Output "Non-compliant: Found RunAsPPL=$currentValue, expected 1."
        exit 1
    }
}
catch {
    Write-Output "Error checking RunAsPPL: $_"
    exit 1
}
