#BUSCA LOCALMENTE EM UM TXT
$Computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt' 

#BUSCA NO AD
 #$computers = Get-ADComputer -Filter * -SearchBase "DC=contoso,DC=corp" | Select-Object -ExpandProperty Name

Write-Host("INICIANDO VALIDAÇÕES...")
Clear-Content -Path C:\Temp\Output\$(get-date -f yyyy-MM-dd)-EncontradonoWSUS.txt
Clear-Content -Path C:\Temp\Output\$(get-date -f yyyy-MM-dd)-NaoEncontradoWSUS.txt

foreach ($computername in $Computers)

{
    
    $ConsultaHost = Get-WsusComputer -NameIncludes "$computername"
    if ($ConsultaHost -match "No computers available.") {

    ##NAOENCONTRADO
    Write-Host "Não encontrado ambiente $computername no WSUS" -ForegroundColor Red
    Add-Content $computername -Path "C:\Temp\Output\$(get-date -f yyyy-MM-dd)-NaoEncontradoWSUS.txt"

    } else

    {
    Write-Host "Encontrado ambiente $computername no WSUS" -ForegroundColor Green
    Add-Content $computername -Path "C:\Temp\Output\$(get-date -f yyyy-MM-dd)-EncontradonoWSUS.txt" }

 }

#$ErrorOccured = $false

#try 
##{ 
#   $ErrorActionPreference = 'Stop'
 #  ...something...
#}
#catch
#{
#   "Error occured"
#   $ErrorOccured=$true
#}
#
#if(!$ErrorOccured) {"No Error Occured"}