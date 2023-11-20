<# PowerShell Script to list applications applications with registered uninstall functionality. 

It should be combined with the list of installed applications within ‘Control Panel – Programs – Programs and Features’ to get cover all applications installed on a system. 

If any key applications appear to be missing in the reports provided, this should be raised for clarification. #>

function Analyze( $p, $f) {
    Get-ItemProperty $p |foreach {
        if (($_.DisplayName) -or ($_.version)) {
            [PSCustomObject]@{
                From = $f;
                Name = $_.DisplayName;
                Version = $_.DisplayVersion;
                Install = $_.InstallDate
            }
        }
    }
}
$s = @()
$s += Analyze 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' 64
$s += Analyze 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' 32
$s | Sort-Object -Property Name | Out-File -FilePath "C:\tmp\application-list.txt"