# Diretório para consulta dos servidores

$Computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt'



# Adicionar os KBs que você está buscando por versão de SO, exemplo abaixo do mês de fevereiro de 2025

$ConsultarKBs_2016 = @("KB5052006") # Adicione mais KB's conforme necessário, exemplo ("KB5051979", "KB50501920")

$ConsultarKBs_2019 = @("KB5052000") # Adicione mais KB's conforme necessário, exemplo ("KB5051979", "KB50501920")

$ConsultarKBs_2022 = @("KB5051979") # Adicione mais KB's conforme necessário, exemplo ("KB5051979", "KB50501920")



# Caminho de saída do relatório que será gerado ao fim da consulta.

$outputPath = "C:\Temp\Output\$(get-date -f yyyy-MM-dd)-KBs-Consulta-Servidores.txt"



# Limpar o conteúdo do arquivo de saída antes da execução

Clear-Content -Path $outputPath -ErrorAction SilentlyContinue



foreach ($computername in $Computers) {

    try {

        # Consultar a versão do sistema operacional

        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername).Version



        # Definir as variáveis de KB's a serem consultadas com base na versão do SO

        if ($osVersion.StartsWith("10.0.14393")) {

            $ConsultarKBs = $ConsultarKBs_2016

            $osName = "Windows Server 2016"

        } elseif ($osVersion.StartsWith("10.0.17763")) {

            $ConsultarKBs = $ConsultarKBs_2019

            $osName = "Windows Server 2019"

        } elseif ($osVersion.StartsWith("10.0.20348")) {

            $ConsultarKBs = $ConsultarKBs_2022

            $osName = "Windows Server 2022"

        } else {

            Write-Host "Versão do sistema operacional não reconhecida no ambiente $computername $osVersion" -ForegroundColor Yellow

            continue

        }

        foreach ($KB in $ConsultarKBs) {

            if (Get-HotFix -Id $KB -ComputerName $computername -ErrorAction SilentlyContinue) {

                Write-Host "O $KB foi encontrado instalado no ambiente $computername ($osName)." -ForegroundColor Green

            } else {

                Write-Host "O $KB não foi encontrado instalado no ambiente $computername ($osName)." -ForegroundColor Red

                Add-Content -Path $outputPath -Value "$computername - $KB - $osName"

            }

        }

    } catch {

        Add-Content -Path $outputPath -Value "$computername - $KB - Erro: $_"

        Write-Host "Ocorreu um problema com a comunicação no ambiente $computername $_" -ForegroundColor Red

    }

}



Write-Host "Gerando Relatório e Armazenando em: $outputPath" -ForegroundColor Cyan