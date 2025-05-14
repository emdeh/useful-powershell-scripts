<#
.DESCRIPTION
    Intune Remediation: Remove all per-user Cisco Webex installs.
    - Kills running Webex processes under user profile
    - Attempts silent MSI uninstalls for all HKCU uninstall entries
    - Deletes remaining Webex folders in LOCALAPPDATA/APPDATA
    - Removes HKCU uninstall registry keys
    - Clears any Webex auto-start (Run) entries
    Returns 0 on success, 1 on error.
    Author: emdeh
    Version: 1.1.2
#>

try {
    ## Step 1: Identify per-user Webex installs
    $paths = @(
        "$env:LOCALAPPDATA\Programs\Cisco Spark",
        "$env:LOCALAPPDATA\CiscoSpark",
        "$env:LOCALAPPDATA\WebEx",
        "$env:APPDATA\Webex",
        "$env:LOCALAPPDATA\CiscoSparkLauncher"
    )
    $foundPaths = $paths | Where-Object { Test-Path $_ }

    $uninstallRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $nameRegex     = '(?i)webex|cisco spark'
    $foundRegs = Get-ItemProperty -Path $uninstallRoot -ErrorAction SilentlyContinue |
        Where-Object {
            ($_.DisplayName     -match $nameRegex) -or
            ($_.UninstallString -match $nameRegex)
        }

    if (-not $foundPaths -and -not $foundRegs) {
        Write-Output 'No user-context Webex found. Nothing to remediate.'
        exit 0
    }

    Write-Output "Detected Webex folders: $($foundPaths -join ', ')"
    Write-Output "Detected uninstall entries: $($foundRegs.Count)"

    ## Step 2: Terminate any Webex processes running from those folders
    $allProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path }
    $toStop = $allProcs | Where-Object {
        foreach ($wp in $foundPaths) {
            if ($_.Path.StartsWith($wp, [StringComparison]::InvariantCultureIgnoreCase)) {
                return $true
            }
        }
        return $false
    }

    if ($toStop) {
        foreach ($p in $toStop) {
            Write-Output "Stopping process '$($p.Name)' (PID $($p.Id))"
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        Write-Output 'No running Webex processes to stop.'
    }

    ## Step 3: Silent MSI uninstall for each detected registry entry
    foreach ($reg in $foundRegs) {
        $dispName = if ($reg.DisplayName) { $reg.DisplayName } else { $reg.PSChildName }
        $uninst   = $reg.UninstallString
        Write-Output "Processing uninstall entry: $dispName"

        if ($uninst -and ($uninst -match 'MsiExec\.exe')) {
            $args = $uninst -replace '/I', '/X'
            if ($args -notmatch '/X')  { $args = "/X $args" }
            if ($args -notmatch '/qn') { $args += ' /qn /norestart' }

            Write-Output "Running silent MSI uninstall: msiexec.exe $args"
            Start-Process -FilePath 'msiexec.exe' `
                          -ArgumentList $args `
                          -Wait `
                          -NoNewWindow `
                          -ErrorAction SilentlyContinue
        }
        else {
            Write-Output "No silent MSI uninstall for $dispName will clean up manually."
        }
    }

    ## Step 4a: Delete all detected Webex folders
    foreach ($path in $foundPaths) {
        if (Test-Path $path) {
            Write-Output "Deleting folder: $path"
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            }
            catch {
                Write-Output "[WARN] Failed to delete ${path}: $_"
            }
        }
        else {
            Write-Output "Folder already removed: $path"
        }
    }

    ## Step 4b: Remove all HKCU uninstall registry keys
    foreach ($reg in $foundRegs) {
        $keyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$($reg.PSChildName)"
        Write-Output "Removing registry key: $keyPath"
        try {
            Remove-Item -Path $keyPath -Recurse -Force -ErrorAction Stop
        }
        catch {
            Write-Output "[WARN] Failed to remove registry key ${keyPath}: $_"
        }
    }

    ## Step 4c: Remove Webex auto-start entries
    $runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $runValues = Get-ItemProperty -Path $runKey -ErrorAction SilentlyContinue |
        Get-Member -MemberType NoteProperty |
        Select-Object -ExpandProperty Name |
        Where-Object { $_ -match $nameRegex }

    foreach ($val in $runValues) {
        Write-Output "Removing auto-start entry: $val"
        try {
            Remove-ItemProperty -Path $runKey -Name $val -ErrorAction Stop
        }
        catch {
            Write-Output "[WARN] Failed to remove auto-start value ${val}: $_"
        }
    }

    # Step 5: Delete Webex shortcuts from Start Menu
    $startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    # Look for any .lnk whose name contains “webex”, “spark”, or “cisco”
    $shortcutPatterns = '*webex*.lnk','*spark*.lnk','*cisco*.lnk'

    $shortcuts = Get-ChildItem -Path $startMenu -Recurse -Include $shortcutPatterns -ErrorAction SilentlyContinue
    foreach ($sc in $shortcuts) {
    Write-Output "Removing Start Menu shortcut: $($sc.FullName)"
    Remove-Item -Path $sc.FullName -Force -ErrorAction SilentlyContinue
    }

    ## Step 6: Remove any Webex installer packages from Downloads
    $dl = Join-Path $env:USERPROFILE 'Downloads'
    Get-ChildItem -Path $dl -Include '*.msi','*.exe' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '(?i)webex|spark' } |
        ForEach-Object {
            Write-Output "Removing installer from Downloads: $($_.FullName)"
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }

    Write-Output 'Remediation complete: exiting with code 0.'
    exit 0
}
catch {
    Write-Output "Error during remediation: $_"
    exit 1
}
