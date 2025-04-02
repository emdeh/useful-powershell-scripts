<#
.DESCRIPTION
    Checks if the PowerShell Transcripts folder size exceeds 10000 KB.
    Returns exit code 0 if compliant or not applicable, 1 if non-compliant or error.
    Author: emdeh
    Version: 1.0.1
#>

$folderPath = 'C:\ProgramData\Logs\PowerShellTranscripts'
$maxSizeKB = 75

try {
    if (-not (Test-Path $folderPath)) {
        Write-Output "Warning: Transcript folder does not exist. Check policy."
        exit 0
    }

    $folderSizeBytes = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
    $folderSizeKB = [math]::Round($folderSizeBytes / 1KB, 2)

    if ($folderSizeKB -gt $maxSizeKB) {
        Write-Output "Non-compliant: Folder size is $folderSizeKB KB, exceeds $maxSizeKB KB."
        exit 1
    }
    else {
        Write-Output "Compliant: Folder size is $folderSizeKB KB."
        exit 0
    }
}
catch {
    Write-Output "Error checking folder size: $_"
    exit 1
}
