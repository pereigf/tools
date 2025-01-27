# Diretório dos servidores de busca
$Computers = Get-Content -Path 'C:\Temp\Servers_WSUS_History.txt'

# Adicionar os KBs que você está buscando
$ConsultarKBs = @("KB5035885", "KB5026372") # Adicione mais KBs conforme necessário

# Caminho de saída
$outputPath = "C:\Temp\Output\$(get-date -f yyyy-MM-dd)-KBs-Faltando-Servidores.txt"

# Limpar o conteúdo do arquivo de saída anterior
Clear-Content -Path $outputPath -ErrorAction SilentlyContinue

foreach ($computername in $Computers) {
    foreach ($KB in $ConsultarKBs) {
        try {
            if (Get-HotFix -Id $KB -ComputerName $computername -ErrorAction SilentlyContinue) {
                Write-Host "O $KB foi encontrado instalado no ambiente $computername." -ForegroundColor Green
            } else {
                Write-Host "O $KB não foi encontrado instalado no ambiente $computername." -ForegroundColor Red
                Add-Content -Path $outputPath -Value "$computername - $KB"
            }
        } catch {
            Add-Content -Path $outputPath -Value "$computername - $KB"
            Write-Host "Ocorreu um problema com a comunicação no ambiente $computername $_" -ForegroundColor Red
        }
    }
}

Write-Host "Gerando Relatório e Armazenando em: $outputPath" -ForegroundColor Cyan
