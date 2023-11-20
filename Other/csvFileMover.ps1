$client = New-Object System.Net.Sockets.TCPClient('127.0.0.1',4321)
# Temporarily bypass the PowerShell script execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define variables
$sourceFolder = "$env:USERPROFILE\Downloads"
$destinationFolder = "C:\Path\To\Destination"
$csvFileName = Get-ChildItem -Path $sourceFolder -Filter "FileName*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$newFileName = "NewFileName.csv"
$supercededFileName = "Superceded-with-new-file-$newFileName"

# Check if the CSV file exists in Downloads
if ($csvFileName -eq $null) {
    Write-Host "No CSV file starting with FileName found in the Downloads folder."
    Exit
}

# Check if the file already exists in the Destination folder, rename if it does
if (Test-Path "$destinationFolder\$newFileName") {
    Rename-Item -Path "$destinationFolder\$newFileName" -NewName $supercededFileName
}

# Copy the new file to the locally synced Destination folder
Copy-Item -Path "$sourceFolder\$($csvFileName.Name)" -Destination "$destinationFolder\$newFileName"

Write-Host "CSV file copied to SharePoint and renamed successfully."
