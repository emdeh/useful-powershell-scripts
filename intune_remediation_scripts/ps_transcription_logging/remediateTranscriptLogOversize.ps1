<#
.DESCRIPTION
    Deletes all subfolders under the PowerShell Transcripts folder that are older than XX days.
    Returns exit code 0 on success, 1 on error.
    Author: emdeh
    Version: 1.0.0
#>

$folderPath = 'C:\ProgramData\Logs\PowerShellTranscripts'
$daysOld = 90

try {
    if (-not (Test-Path $folderPath)) {
        Write-Output "Warning: Transcript folder does not exist. Check policy."
        exit 0
    }

    $threshold = (Get-Date).AddDays(-$daysOld)

    Get-ChildItem -Path $folderPath -Directory -Force -ErrorAction Stop | Where-Object {
        $_.LastWriteTime -lt $threshold
    } | ForEach-Object {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
        Write-Output "Deleted folder: $($_.FullName)"
    }

    Write-Output "Remediation completed: Old folders deleted."
    exit 0
}
catch {
    Write-Output "Error during remediation: $_"
    exit 1
}


