$username = 'contoso\pereirag'
$password = 'SuaSenha'
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$Computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt'


foreach ($computername in $Computers) {

    try {
       #COPIA O KB PARA O SERVIDOR // CRIAR PASSO PARA EXCLUIR PERMANENTE PÓS INSTALAÇÃO.
       Write-Host ""
       Write-Host "INICIANDO CÓPIA DO PACOTE (KB) PARA O SERVIDOR $($computername)." -ForegroundColor Green
       Copy-Item "\\srvwkst02-dc\tools\Updates\Cumulative-05_2024" -Destination "\\$computername\C$\Temp\Updates\Cumulative-05_2024" -Recurse
  }

    catch { "Ocorreu um problema com o ambiente $computername, $_"}
     #Write-Host $_   

}