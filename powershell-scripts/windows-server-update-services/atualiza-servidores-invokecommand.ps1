
$Username = 'copntoso\pereirag'
$Password = 'Senha'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

$comando = {Install-WindowsUpdate -AcceptAll -AutoReboot}
$computers = Get-Content -Path 'C:\Temp\Servers_WSUS.txt'

$Computers | foreach {
    try {
        (Invoke-Command -ComputerName $_ -ScriptBlock $comando -credential $Cred  -Verbose)
        

    }
     catch {      "Ocorreu um problema com o ambiente: $_"}
}
