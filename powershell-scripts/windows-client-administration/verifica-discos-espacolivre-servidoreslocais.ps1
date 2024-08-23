# Caminho do arquivo com a lista de servidores
$caminhoArquivoServidores = "C:\temp\servidores.txt"

# Caminho do arquivo de saída .csv
$caminhoArquivoCSV = "C:\temp\resultado_espaco_em_disco.csv"

# Inicializar a lista de resultados
$resultados = @()

# Ler a lista de servidores do arquivo
$servidores = Get-Content -Path $caminhoArquivoServidores

# Para cada servidor na lista
foreach ($servidor in $servidores) {
    # Tentativa de conexão remota
    try {
        Write-Host ""  # Linha em branco para separar a saída
        # Obter as informações dos discos e espaço livre
        $discos = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $servidor -Filter "DriveType=3"

        # Exibir as informações e armazenar para o CSV
        foreach ($disco in $discos) {
            $nomeDrive = $disco.VolumeName
            $espacoLivreGB = "{0:N2}" -f ($disco.FreeSpace / 1GB)
            $tamanhoTotalGB = "{0:N2}" -f ($disco.Size / 1GB)
            $percentualLivre = ($disco.FreeSpace / $disco.Size) * 100

            # Exibe o resultado com a cor correspondente
            if ($percentualLivre -gt 60) {
                Write-Host "Servidor: $servidor - Unidade: $($disco.DeviceID) - Nome do Drive: $nomeDrive - Espaço Livre: $espacoLivreGB GB - Tamanho Total: $tamanhoTotalGB GB" -ForegroundColor Green
            } else {
                Write-Host "Servidor: $servidor - Unidade: $($disco.DeviceID) - Nome do Drive: $nomeDrive - Espaço Livre: $espacoLivreGB GB - Tamanho Total: $tamanhoTotalGB GB" -ForegroundColor Red
            }

            # Adicionar os resultados à lista para exportação
            $resultados += [PSCustomObject]@{
                Servidor = $servidor
                Unidade = $disco.DeviceID
                "Nome do Drive" = $nomeDrive
                "Espaço Livre (GB)" = $espacoLivreGB
                "Tamanho Total (GB)" = $tamanhoTotalGB
                "Percentual Livre (%)" = "{0:N2}" -f $percentualLivre
            }
        }
    } catch {
        Write-Host "Falha ao conectar ao servidor: $servidor" -ForegroundColor Red
    }
}

# Exportar os resultados para um arquivo CSV após exibir na tela
$resultados | Export-Csv -Path $caminhoArquivoCSV -NoTypeInformation -Delimiter ";"

Write-Host "Resultado salvo em $caminhoArquivoCSV"
