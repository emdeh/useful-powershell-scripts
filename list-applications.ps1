# output a list of installed applications with registered uninstall functionality
# from ASD Essential Eight material

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