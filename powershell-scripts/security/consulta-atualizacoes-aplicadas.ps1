$computers = Get-Content -Path 'C:\Temp\Servers_Updates.txt'
$outputFile = "C:\temp\2025-05-SecurityPatchs.csv"
$results = @()

$comando = {
    try {
        $computerName = [System.Net.Dns]::GetHostName()
        $osInfo = Get-CimInstance Win32_OperatingSystem
        $hotfixes = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 6

        $hotfixes | ForEach-Object {
            [PSCustomObject]@{
                ComputerName    = $computerName  
                OperatingSystem = $osInfo.Caption  # Adicionando coluna de sistema operacional
                HotFixID        = if ($_.HotFixID) { $_.HotFixID.ToString().Trim() } else { "Não informado" }  
                InstalledOn     = if ($_.InstalledOn) { $_.InstalledOn.ToString("yyyy-MM-dd") } else { "Não informado" }
                Description     = $_.Description
            }
        }
    }
    catch {
        Write-Host "Erro ao obter informações em $computerName"
    }
}

$computers | ForEach-Object {
    try {
        Write-Host "`nBuscando atualizações em $_..."
        $hotfixes = Invoke-Command -ComputerName $_ -ScriptBlock $comando -Verbose
        $results += $hotfixes

        # Exibe os resultados formatados no console antes da exportação
        $hotfixes | Format-Table ComputerName, OperatingSystem, HotFixID, InstalledOn, Description -AutoSize
    }
    catch {
        Write-Host "Ocorreu um problema ao acessar o ambiente: $_"
    }
}

# Salva os resultados no arquivo CSV, incluindo o Sistema Operacional
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Arquivo CSV salvo em $outputFile"