# Importa o módulo Active Directory (necessário no controlador de domínio)
Import-Module ActiveDirectory

# Função para obter o endereço IP de cada computador
function Get-IP {
    param (
        [string]$ComputerName
    )
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($ComputerName) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
        if ($ip) {
            return $ip.IPAddressToString
        } else {
            return "IP não encontrado"
        }
    } catch {
        return "Erro ao obter IP"
    }
}

# Define um filtro para buscar objetos de computador que possuem sistemas operacionais mais antigos ou iguais ao Windows Server 2012
$servidoresAntigos = Get-ADComputer -Filter {OperatingSystem -like "*Windows Server*"} -Property OperatingSystem | Where-Object {
    $_.OperatingSystem -match "Windows Server 2003|Windows Server 2008|Windows Server 2012"
}

# Adiciona uma coluna para o endereço IP e exibe os resultados
$servidoresAntigos | ForEach-Object {
    $ipAddress = Get-IP $_.Name
    [PSCustomObject]@{
        Name            = $_.Name
        OperatingSystem = $_.OperatingSystem
        IPAddress       = $ipAddress
    }
} | Format-Table -AutoSize

# Opcional: Se quiser salvar o resultado em um arquivo CSV
$servidoresAntigos | ForEach-Object {
    $ipAddress = Get-IP $_.Name
    [PSCustomObject]@{
        Name            = $_.Name
        OperatingSystem = $_.OperatingSystem
        IPAddress       = $ipAddress
    }
} | Export-Csv -Path "C:\servidores_antigos_com_ip.csv" -NoTypeInformation
