# ML3: Windows PowerShell 2.0 is disabled or removed:

Get-WindowsOptionalFeature -online | Where-Object {$_.FeatureName -match “PowerShellv2”}