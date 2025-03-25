<#
.DESCRIPTION
    Checks if the QuicAllowed registry key is set to a specified DWORD value (0).
    Returns exit code 0 if compliant, 1 if non-compliant or any error.
	Author: emdeh
    Version: 1.0.0
#>

$regKey = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
$name   = 'QuicAllowed'
$value  = 0

try {
    if (-not (Test-Path $regKey)) {
        Write-Output 'Non-compliant: Registry key does not exist.'
        exit 1
    }

    $currentValue = (Get-ItemProperty -Path $regKey -Name $name -ErrorAction SilentlyContinue).$name
    
    if ($currentValue -eq $value) {
        Write-Output 'Compliant: QuicAllowed is set to 0.'
        exit 0
    }
    else {
        Write-Output "Non-compliant: Found QuicAllowed=$currentValue, expected 0."
        exit 1
    }
}
catch {
    Write-Output "Error checking QuicAllowed: $_"
    exit 1
}