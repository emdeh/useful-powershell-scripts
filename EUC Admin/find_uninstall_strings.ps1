Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -like "*Adobe*" } | Select-Object DisplayName, DisplayVersion, Publisher, UninstallString

# Finds the registry uninstall strings for the objects matching the DisplayName search.