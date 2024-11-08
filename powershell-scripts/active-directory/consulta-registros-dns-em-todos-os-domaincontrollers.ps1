<#
'Como utilizar
'------------------------------------------------------------------------------------
'1 - Crie a pasta "Temp" dentro do diretório C:\"
'2 - Crie um arquivo do tipo texto chamado "ListaBuscaDNS.txt" e deixe ele dentro de C:\Temp"
'3 - Adicione todos os IP's dos registros de DNS que você deseja buscar, dentro do arquivo "C:\Temp\ListaChecagemDNS.txt"
'4 - Caso for necessário, altere a 12º linha de código para indicar a OU de Domain Controllers do seu ambiente.
'5 - Caso você deseje validar se o registro DNS está dentro de todos os controladores de dominio, todas as linhas de código que possuirem a função "break", comente elas com o simbolo #
#>

# Define a quantidade máxima de servidores por bloco, devido à limitação do Resolve-DnsName para até 5 servidores de AD por vez.
$maxServidoresPorBloco = 5
$ServidoresAD = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=ambiental,DC=corp" | Select-Object -ExpandProperty Name
$ListaBuscaDNS = Get-Content -Path 'C:\Temp\ListaBuscaDNS.txt'

function BuscaRegistroDNS {
    # Define o caminho dos arquivos CSV de saída
    $dataAtual = Get-Date -Format dd-MM-yyyy
    $caminhoExistentes = "C:\Temp\$dataAtual-Registros-Existentes-DNS.csv"
    $caminhoInexistentes = "C:\Temp\$dataAtual-Registros-Inexistentes-DNS.csv"

    # Exclui os arquivos CSV se já existirem
    if (Test-Path $caminhoExistentes) {
        Remove-Item $caminhoExistentes -Force
    }
    if (Test-Path $caminhoInexistentes) {
        Remove-Item $caminhoInexistentes -Force
    }

    
    # Inicializa os arquivos CSV com cabeçalhos
    @() | Export-Csv -Path $caminhoExistentes -NoTypeInformation -Force
    @() | Export-Csv -Path $caminhoInexistentes -NoTypeInformation -Force

    # Divide a lista de servidores em blocos de até $maxServidoresPorBloco
    $ServidoresEmBlocos = $ServidoresAD | ForEach-Object -Begin { $grupo = @() } -Process {
        $grupo += $_
        if ($grupo.Count -ge $maxServidoresPorBloco) {
            $grupo
            $grupo = @()
        }
    } -End { if ($grupo) { $grupo } }

    foreach ($IP in $ListaBuscaDNS) {
        $registroEncontrado = $false
        # Itera por cada bloco de servidores
        foreach ($blocoServidores in $ServidoresEmBlocos) {
            try {
                # Realiza a consulta DNS reversa para o IP no bloco atual de servidores
                $resultadoDNS = Resolve-DnsName -Name $IP -Server $blocoServidores -ErrorAction Stop
                $hostname = $resultadoDNS.NameHost
                $registroEncontrado = $true

                Write-Host "ENCONTRADO REGISTRO $IP EM $blocoServidores com o nome $hostname" -ForegroundColor Green
                
                # Adiciona o registro ao arquivo CSV de existentes
                $registroExistente = [PSCustomObject]@{
                    IP         = $IP
                    ServidorAD = ($blocoServidores -join ", ")
                    Status     = "Encontrado"
                    RegistroDNS   = $hostname
                }
                $registroExistente | Export-Csv -Path $caminhoExistentes -NoTypeInformation -Append
                break # Interrompe a busca se o registro já foi encontrado
            }
            catch {
                # Caso não encontre, apenas continue para o próximo bloco de servidores
                Write-Host "NAO ENCONTRADO $IP EM $blocoServidores" -ForegroundColor Red
                break # Interrompe a busca se o registro já não foi encontrado
            }
        }

        # Se o registro DNS não foi encontrado em nenhum bloco de servidores, registra como inexistente
        if (-not $registroEncontrado) {
            $registroInexistente = [PSCustomObject]@{
                IP         = $IP
                ServidorAD = ($ServidoresAD -join ", ")
                Status     = "Nao Encontrado"
                RegistroDNS   = "N/A"
            }
            $registroInexistente | Export-Csv -Path $caminhoInexistentes -NoTypeInformation -Append
            #break # Interrompe a busca se o registro já não foi encontrado
        }
    }

    # Exibe os resultados em uma interface gráfica (Out-GridView) após o processo de busca
    $resultadosExistentes = Import-Csv -Path $caminhoExistentes
    $resultadosInexistentes = Import-Csv -Path $caminhoInexistentes

    # Combina os resultados existentes e inexistentes e exibe em uma única interface gráfica
    $resultadosExistentes + $resultadosInexistentes | Out-GridView -Title "Resultados de Registros DNS"
}

# Executa a função
BuscaRegistroDNS
