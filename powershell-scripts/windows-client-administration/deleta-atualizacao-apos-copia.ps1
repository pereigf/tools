# Definir credenciais
##$username = 'contoso\pereirag'
#$password = 'suasenha'
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username, (ConvertTo-SecureString -String $password -AsPlainText -Force))

# Caminho do arquivo com a lista de servidores
$serversFilePath = 'C:\Temp\ListaChecagem.txt'

# Caminho do arquivo de log
$logFile = "C:\Temp\StatusRemocaoKB.txt"

# Função para escrever no arquivo de log
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFile -Value ("{0} {1}" -f (Get-Date), $message)
}

# Função para remover pacotes
function Remove-Packages {
    param (
        [string]$serversFilePath
    )

    # Lê a lista de servidores do arquivo TXT
    $servers = Get-Content -Path $serversFilePath

    foreach ($server in $servers) {
        $destinationPath = "\\$server\C$\Temp\2025-01\Windows Server 2016"
        try {
            # Remove os pacotes
            Write-Host "INICIANDO O DELETE DO PACOTE (KB) DO SERVIDOR $($server)." -ForegroundColor Red
            Remove-Item -Path $destinationPath -Recurse -Force

            # Verifica se a remoção foi bem sucedida
            if (-Not (Test-Path -Path $destinationPath)) {
                Write-Log "Remoção para $server foi bem sucedida."
                Write-Output "Remoção para $server foi bem sucedida."
            } else {
                throw "A remoção para $server falhou: o diretório de destino ainda existe."
            }
        } catch {
            Write-Log "Falha ao remover de $server $_"
            Write-Output "Falha ao remover de $server $_"
        }
    }
}

# Executa a função de remover pacotes
Remove-Packages -serversFilePath $serversFilePath
