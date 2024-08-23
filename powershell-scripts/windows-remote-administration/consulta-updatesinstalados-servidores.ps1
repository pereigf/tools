# Lê a lista de servidores do arquivo C:\Temp\ListaChecagem.txt
$servidores = Get-Content -Path "C:\Temp\DomainControllers-Ambiental.txt"

# Cria listas para armazenar as informações
$report = @()
$failedServers = @()

foreach ($Server in $servidores) {
    try {
        Write-Host "Tentativa de coleta de informações do ambiente: $Server" -ForegroundColor Green
        $hotfixes = Get-HotFix -Description Security* -ComputerName $Server | Sort-Object -Property InstalledOn -Descending
        $osVersion = (Get-WmiObject -Class Win32_OperatingSystem -Namespace "root\cimv2" -ComputerName $Server).Caption

        foreach ($hotfix in $hotfixes[0..3]) {
            $kb = $hotfix.HotFixID
            $details = Get-WmiObject -Class Win32_QuickFixEngineering -Filter "HotFixID='$kb'" -ComputerName $Server
            $report += [PSCustomObject]@{
                'Destino' = $Server
                'SO' = $osVersion
                'KB' = $kb
                'Descricao' = $details.Description
                'Data de Instalacao' = $hotfix.InstalledOn
            }
        }
    } catch {
        Write-Host "Não foi possível obter informações do ambiente: $Server" -ForegroundColor Red
        $failedServers += [PSCustomObject]@{
            'Servidor' = $Server
            'Status' = "Falha ao coletar informacoes"
        }
    }
}

# Define os caminhos para salvar os arquivos CSV
$csvPath = "C:\Temp\Output\RelatorioHotfixes.csv"
$failedCsvPath = "C:\Temp\Output\FalhaColetaHotfixes.csv"

# Exporta os dados para arquivos CSV
$report | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
$failedServers | Export-Csv -Path $failedCsvPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Relatório de hotfixes exportado para $csvPath" -ForegroundColor Cyan
Write-Host "Relatório de falhas exportado para $failedCsvPath" -ForegroundColor Cyan
