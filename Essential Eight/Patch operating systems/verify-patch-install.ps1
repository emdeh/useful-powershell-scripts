# Verify if an update is installed and write computer names to a file

$A = Get-Content -Path ./Servers.txt
$A | ForEach-Object { if (!(Get-HotFix -Id KB957095 -ComputerName $_))
     { Add-Content $_ -Path ./Missing-KB957095.txt }}
     
<# The `$A` variable contains computer names that were obtained by `Get-Content` from a text file. The objects in `$A` are sent down the pipeline to `ForEach-Object`. An `if` statement uses the `Get-Hotfix` cmdlet with the **Id** parameter and a specific Id number for each computer name. If a computer doesn't have the specified hotfix Id installed, the `Add-Content` cmdlet writes the computer name to a file. #>

# Get the most recent hotfix on the local computer

(Get-HotFix | Sort-Object -Property InstalledOn)[-1]