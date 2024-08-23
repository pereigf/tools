
$Username = 'contoso\pereirag'
$Password = 'Senha'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

$comando = {Get-Service -Name wuauserv} #BuscaStatusServiçoWindowsUpdate
$comando1 = {Set-Service -Name wuauserv -StartupType Disabled} #SetaServiçoWindowsUpdateComoDisabled

$computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt'

$Computers | foreach {
    try {

        Invoke-Command -ComputerName $_ -ScriptBlock $comando -credential $Cred  -Verbose #StopService
        Invoke-Command -ComputerName $_ -ScriptBlock $comando1 -credential $Cred  -Verbose #DisableService

    }
     catch {      "Ocorreu um problema com o ambiente: $_"}
}
