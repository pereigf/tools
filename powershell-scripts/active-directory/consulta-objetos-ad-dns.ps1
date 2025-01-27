#BUSCA LOCALMENTE EM UM TXT
$Computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt' 

#BUSCA EM TODO O DOMINIO
$BuscaAD = Get-ADComputer -Filter * -SearchBase "DC=contoso,DC=corp" | Select-Object -ExpandProperty Name

function BuscaRegistroDNS {

Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Existentes-DNS.txt -ErrorAction SilentlyContinue
Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Inexistentes-DNS.txt -ErrorAction SilentlyContinue

foreach ($server in $Computers)

{
try {

            Resolve-DnsName -Name $server -Type A -ErrorAction Stop | Out-Null
            Write-Host "ENCONTRADO REGISTRO $($server) NO DNS" -ForegroundColor Green
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Existentes-DNS.txt -Value $server
        }

        catch {

            Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS" -ForegroundColor Red
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Inexistentes-DNS.txt -Value $server
            #Resolve-DnsName -Name $server -Type A -ErrorAction SilentlyContinue
            #Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS"
        }    
}
        Start-Sleep -s 3
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Existentes-DNS " -ForegroundColor Cyan
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Inexistentes-DNS " -ForegroundColor Cyan

}
function BuscaRegistroDNS_TodoDominio {

Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Existentes-DNS.txt -ErrorAction SilentlyContinue
Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Inexistentes-DNS.txt -ErrorAction SilentlyContinue

foreach ($server in $BuscaAD)

{

try {
        Resolve-DnsName -Name $server -Type A -ErrorAction Stop | Out-Null
        Write-Host "ENCONTRADO REGISTRO $($server) NO DNS" -ForegroundColor Green
        Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Existentes-DNS.txt -Value $server
      }

        catch {

            Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS" -ForegroundColor Red
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Inexistentes-DNS.txt -Value $server
            #Resolve-DnsName -Name $server -Type A -ErrorAction SilentlyContinue
            #Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS"
         
        }   

        
}
        Start-Sleep -s 3
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Existentes-DNS " -ForegroundColor Cyan
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Inexistentes-DNS " -ForegroundColor Cyan
}
function Menu_Show {
    param (
        [string]$Title = 'VALIDADOR ADNS + GERADOR DE RELATÓRIO'
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. PROCURAR OBJETOS NO ACTIVE DIRECTORY BASEADO EM .TXT | (C:\Temp\ListaChecagem.txt)"
    Write-Host ""
    Write-Host "2. PROCURAR OBJETOS NO ACTIVE DIRECTORY | EM TODO O DOMINIO"
    Write-Host ""
    Write-Host "3. PROCURAR REGISTROS DE DNS BASEADO EM .TXT | (C:\Temp\ListaChecagem.txt)"
    Write-Host ""
    Write-Host "4. PROCURAR REGISTROS DE DNS | EM TODO O DOMINIO"
    Write-Host ""
    Write-Host "Digite 'S' para sair..."
}
function BuscaObjetoAD {

Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Existentes-ActiveDirectory.txt -ErrorAction SilentlyContinue
Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Inexistentes-ActiveDirectory.txt -ErrorAction SilentlyContinue

foreach ($server in $Computers)

{
try {

            Get-ADComputer $server -ErrorAction Stop | Out-Null
            Write-Host "ENCONTRADO OBJETO $($server) NO ACTIVE DIRECTORY" -ForegroundColor Green
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Existentes-ActiveDirectory.txt -Value $server
         
        }

        catch {

            Write-Host "NÃO ENCONTRADO OBJETO $($server) NO ACTIVE DIRECTORY" -ForegroundColor Red
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Inexistentes-ActiveDirectory.txt -Value $server
            #Resolve-DnsName -Name $server -Type A -ErrorAction SilentlyContinue
            #Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS"
        }    
}
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Objetos-Existentes-ActiveDirectory " -ForegroundColor Cyan
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Objetos-Inexistentes-ActiveDirectory " -ForegroundColor Cyan

}
function BuscaObjetoAD_TodoDominio {

Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Existentes-DNS.txt -ErrorAction SilentlyContinue
Clear-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Registros-Inexistentes-DNS.txt -ErrorAction SilentlyContinue

foreach ($server in $BuscaAD)

{

try {

            Get-ADComputer $server -ErrorAction Stop | Out-Null
            Write-Host "ENCONTRADO OBJETO $($server) NO ACTIVE DIRECTORY" -ForegroundColor Green
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Existentes-ActiveDirectory.txt -Value $server
      }

        catch {

            Write-Host "NÃO ENCONTRADO OBJETO $($server) NO ACTIVE DIRECTORY" -ForegroundColor Red
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Inexistentes-ActiveDirectory.txt -Value $server
            #Resolve-DnsName -Name $server -Type A -ErrorAction SilentlyContinue
            #Write-Host "NÃO ENCONTRADO REGISTRO $($server) NO DNS"
         
        }   

        
}
        Start-Sleep -s 3
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Existentes-DNS " -ForegroundColor Cyan
        Write-Host "Gerando Relatório e Armazenando em: C:\temp\Registros-Ixistentes-DNS " -ForegroundColor Cyan
}
function BuscaObjetosWSUS {

foreach ($server in $Computers)

{
try {
            Get-WsusComputer -NameIncludes $server
            Write-Host "ENCONTRADO OBJETO $($server) NO WSUS" -ForegroundColor Green
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-Existentes-WSUS.txt -Value $server
        }

        catch {

            Write-Host "NÃO ENCONTRADO OBJETO $($server) NO WSUS" -ForegroundColor Red
            Add-Content -Path C:\Temp\$(get-date -f yyyy-MM-dd)-Objetos-NaoExistentes-WSUS.txt -Value $server
        }    
}


}

do
 {
    Menu_Show
    Write-Host "" 
    $selection = Read-Host "Por favor, selecione uma das opcoes"
    switch ($selection)
    {

    '1' {
    &BuscaObjetoAD
    } 
    
    
    '2' {
    &BuscaObjetoAD_TodoDominio

    } 
    
    '3' {
    &BuscaRegistroDNS
    #&BuscaObjetosWSUS
    }
    '4' {
    &BuscaRegistroDNS_TodoDominio 
    }
    }
    pause
 }
 until ($selection -eq 's')