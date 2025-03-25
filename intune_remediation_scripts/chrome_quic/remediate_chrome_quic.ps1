<#
.DESCRIPTION
    Ensures the QuicAllowed registry key is set to 0.
	This remediates sporadic MDE AV Web Protection behaviour in Chrome.
    Creates or updates the key and returns exit code 0 on success, 1 on failure.
	Note this is not a solution, but a workaround until repackaging app.
	Author: emdeh
    Version: 1.0.0
#>

$regKey = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
$name   = 'QuicAllowed'
$value  = 0

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
        Write-Output "Remediation succeeded: Created QuicAllowed=0."
        exit 0
    }
    else {
        # Property exists, update it
        Set-ItemProperty -Path $regKey -Name $name -Value $value -ErrorAction Stop
        Write-Output "Remediation succeeded: Updated QuicAllowed to 0."
        exit 0
    }
}
catch {
    Write-Output "Error setting QuicAllowed: $_"
    exit 1
}


<#
.Additional Notes
	QUIC being enabled can make Defender Web Protection sporadic because QUIC uses UDP instead of TCP, 
	bypassing traditional HTTP/HTTPS traffic inspection mechanisms. Defender Web Protection relies on 
	analyzing HTTP/HTTPS requests to detect malicious activity. Since QUIC traffic is encrypted at the 
	transport layer and does not follow the standard TCP/IP inspection patterns, Defender may be unable 
	to intercept, analyze, or enforce policies effectively. This results in inconsistent protection when 
	users access websites over QUIC. 
	
	Disabling QUIC ensures that all traffic is routed over inspectable protocols, allowing Defender to 
	provide consistent web protection.
	
	Not a ongoing solution - you should repackage the app with the setting disabled.
#>