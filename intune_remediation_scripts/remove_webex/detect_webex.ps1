<#
.DESCRIPTION
    Detects any Cisco Webex installation located in the **current user’s** profile.
    The script checks common per-user folders and HKCU uninstall registry keys.
    Returns exit code 0 if no user-context Webex is found (compliant / not-applicable),
    or exit code 1 if at least one user-context Webex install is detected.
    Author: emdeh
    Version: 1.0.1
#>

# Known per-user install locations
$sparkPathOne = "$env:LOCALAPPDATA\Programs\Cisco Spark"       # Webex App
$sparkPathTwo = "$env:LOCALAPPDATA\CiscoSpark"
$meetingsPath = "$env:LOCALAPPDATA\WebEx"                     # Webex Meetings client
$roamingPath  = "$env:APPDATA\Webex"                          # Roaming data
$launcherPath = "$env:LOCALAPPDATA\CiscoSparkLauncher"        # Updater cache


$found = $false

try {
    # 1) Folder checks
    if (Test-Path $sparkPathOne)    { $found = $true; Write-Output "Webex App folder found: $sparkPathOne" }
    if (Test-Path $sparkPathTwo)    { $found = $true; Write-Output "Webex App folder found: $sparkPathTwo" }
    if (Test-Path $meetingsPath) { $found = $true; Write-Output "Webex Meetings folder found: $meetingsPath" }
    if (Test-Path $roamingPath)  { $found = $true; Write-Output "Roaming Webex data found: $roamingPath" }
    if (Test-Path $launcherPath) { $found = $true; Write-Output "CiscoSparkLauncher folder found: $launcherPath" }

    # 2) HKCU uninstall key check (robust)
    $uninstallRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $nameRegex     = '(?i)webex|cisco spark|webex teams'

    $hkcuMatches = Get-ItemProperty -Path $uninstallRoot -ErrorAction SilentlyContinue |
        Where-Object {
            ($_.DisplayName     -match $nameRegex) -or
            ($_.InstallLocation -match $nameRegex) -or
            ($_.UninstallString -match $nameRegex)
        }

    if ($hkcuMatches) {
        $found = $true
        $hkcuMatches | ForEach-Object {
            $disp = $_.DisplayName
            if (-not $disp) { $disp = $_.UninstallString }   # fallback text
            Write-Output "HKCU uninstall entry: $disp"
        }
    }

    # 3) Final decision
    if ($found) {
        Write-Output 'Non-compliant: User-context Webex installation detected.'
        exit 1
    }
    else {
        Write-Output 'Compliant: No user-context Webex detected.'
        exit 0
    }
}
catch {
    Write-Output "Error during detection: $_"
    exit 1
}
