# Definir a OU para busca
$ou = "OU=Workstations,OU=CACHOEIRO,OU=ES,OU=BR,OU=RJ_ES,OU=Ambiental,DC=ambiental,DC=corp"

# Definir o caminho do arquivo CSV
$csvPath = "C:\Temp\relatorio.csv"

# Consultar objetos na OU e obter os atributos desejados
$computers = Get-ADComputer -SearchBase $ou -Filter * -Property Name, OperatingSystem, OperatingSystemVersion, Description | ForEach-Object {
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($_.Name) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        $ipAddress = $ip.IPAddressToString
    }
    catch {
        $ipAddress = "Desconhecido"
    }
    [PSCustomObject]@{
        NomeServidor         = $_.Name
        IP                   = $ipAddress
        SistemaOperacional   = $_.OperatingSystem
        VersaoSO             = $_.OperatingSystemVersion
        Descricao            = $_.Description
    }
}

# Exportar para CSV
$computers | Select-Object NomeServidor, IP, SistemaOperacional, VersaoSO, Descricao | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Informações exportadas para $csvPath"
