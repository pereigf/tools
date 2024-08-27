net stop wuauserv
net stop cryptSvc
net stop bits
Remove-Item "C:\ProgramData\Microsoft\Group Policy" -Recurse -Force
Remove-Item "C:\WINDOWS\security\Database" -Recurse -Force
Remove-Item "C:\Windows\System32\GroupPolicy\Machine" -Recurse -Force
Remove-Item "C:\Windows\System32\GroupPolicy\Users" -Recurse -Force
secedit /configure /cfg C:\Windows\INF\defltbase.inf /db defltbase.sdb /verbose
REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies /f
REG delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies /f
