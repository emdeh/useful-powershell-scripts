# Get AppLocker Policies

Get-AppLockerPolicy -Effective -Xml | Set-Content ('c:\windows\temp\curr.xml')`

Get-AppLockerPolicy -Local | Test-AppLockerPolicy -Path C:\Windows\System32\*.exe -User Everyone

# Test AppLocker Policies

Test-AppLockerPolicy -XMLPolicy C:\windows\temp\curr.xml -Path C:\windows\system32\calc.exe, C:\windows\system32\notepad.exe -User Everyone