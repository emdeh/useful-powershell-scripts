# ML1: Privileged accounts can't access the internet:

Get-ADUser -Filter {(admincount -eq 1) -and (emailaddress -like “*”) -and (enabled -eq $true)} -Properties EmailAddress | Select samaccountname, emailaddress