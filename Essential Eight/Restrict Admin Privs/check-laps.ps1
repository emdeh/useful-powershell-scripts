# ML2: Check if all computers have LAPS configured, run the following PowerShell commands and compare the output:

Get-ADComputer -Filter {ms-Mcs-AdmPwdExpirationTime -like “*”} -Properties ms-Mcs-AdmPwdExpirationTime | measure

# and

Get-ADComputer -Filter {Enabled -eq $true} | measure