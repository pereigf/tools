# Caminho para o arquivo de texto com a lista de servidores
$servers = Get-Content -Path "C:\temp\servidores.txt"

# Caminho para salvar o resultado
$resultFile = "C:\temp\resultado.csv"

# Definir as versões do Windows 10 e suas respectivas builds finais com suporte
$versoesSuportadas = @{
    "19044" = "Windows 10, Version 21H2"
    "19045" = "Windows 10, Version 22H2"
    # Adicione mais versões conforme necessário
}

# Criar lista para armazenar os resultados
$resultados = @()

foreach ($server in $servers) {
    try {
        # Estabelece uma conexão remota com o servidor
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server

        # Extrai a versão, build e hostname do sistema operacional
        $version = $osInfo.Version
        $build = $osInfo.BuildNumber
        $hostname = $osInfo.CSName

        # Obter o endereço IP do servidor
        $ipAddress = (Test-Connection -ComputerName $server -Count 1).IPV4Address.IPAddressToString

        # Verificar se a build tem suporte
        if ($versoesSuportadas.ContainsKey($build)) {
            $resultado = [PSCustomObject]@{
                Hostname = $hostname
                IP = $ipAddress
                Versão = $versoesSuportadas[$build]
                Build = $build
                Status = "Suportado"
            }
        } else {
            # Determinar a versão correspondente
            switch ($build) {
                "19041" { $versao = "Windows 10, Version 2004" }
                "19042" { $versao = "Windows 10, Version 20H2" }
                "19043" { $versao = "Windows 10, Version 21H1" }
                default { $versao = "Versão desconhecida ou fora do escopo" }
            }

            # Adicionar resultado de versão sem suporte
            $resultado = [PSCustomObject]@{
                Hostname = $hostname
                IP = $ipAddress
                Versão = $versao
                Build = $build
                Status = "Não Suportado"
            }
        }

        # Adiciona o resultado à lista
        $resultados += $resultado
    }
    catch {
        Write-Warning "Não foi possível conectar ao servidor $server"
        $resultado = [PSCustomObject]@{
            Hostname = $server
            IP = "Erro de conexão"
            Versão = "Erro de conexão"
            Build = "Erro de conexão"
            Status = "Erro de conexão"
        }
        $resultados += $resultado
    }
}

# Exporta os resultados para um arquivo CSV
$resultados | Export-Csv -Path $resultFile -NoTypeInformation -Encoding UTF8

Write-Host "Verificação concluída. Resultados salvos em $resultFile"