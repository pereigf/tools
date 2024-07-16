#CRIE UM TXT COM OS SERVIDORES QUE VOCÊ QUER CONSULTAR E ADICIONE O LOCAL DELE ABAIXO.
$listcomputers = Get-Content -Path 'C:\Temp\ListaServidores.txt'
$accountname = 'NomeDaConta'
#ADICIONE O NOME DA CONTA NA VÁRIAVEL $ACCOUNTNAME

foreach ($computer in $listcomputers) {
    
    $services = Get-WmiObject Win32_Service | Select-Object name,startname
    foreach ($service in $services) {

    if ($service.startname -eq $accountname) {
    Write-Host "A conta $accountname está configurada no serviço $($service.name) no servidor $computer."
    }
    }
}