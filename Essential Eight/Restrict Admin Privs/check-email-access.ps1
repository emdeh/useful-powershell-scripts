# Check if privileged accounts have access to mailboxes and email addresses:

Get-ADUser -Filter {(admincount -eq 1) -and (emailaddress -like "*") -and (enabled -eq $true)} –``Properties EmailAddress | Select samaccountname, emailaddress`