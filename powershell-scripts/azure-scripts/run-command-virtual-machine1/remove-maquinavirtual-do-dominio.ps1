$password = ConvertTo-SecureString "SENHA" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("pereirag@contoso.corp", $password)
Remove-Computer -UnjoinDomainCredential $Cred -Force -Restart