#O SCRIPT ABAIXO CONSULTA TODOS OS SERVIÇOS LOCAIS DOS SERVIDORES NO TXT E VERIFICA SE A CONTA MENCIONADA ESTÁ CONFIGURADA EM ALGUM DOS SERVIÇOS LOCAIS.

#CRIE UM TXT COM OS SERVIDORES QUE VOCÊ QUER CONSULTAR E ADICIONE O LOCAL DELE ABAIXO.
$listservers = Get-Content -Path 'C:\Temp\ad_teste.txt'
$accountname = 'NomeDaConta'
#ADICIONE O NOME DA CONTA NA VÁRIAVEL $ACCOUNTNAME

foreach ($computer in $listservers) {
    
    $services = Get-WmiObject Win32_Service | Select-Object name,startname
    foreach ($service in $services) {

    if ($service.startname -eq $accountname) {
    Write-Host "A conta $accountname está configurada no serviço $($service.name) no servidor $computer."
    }
    }
}