# Definir credenciais, SOMENTE SE NECESSÁRIO.
#$username = 'contoso\pereirag'
#$password = 'suasenha'
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username, (ConvertTo-SecureString -String $password -AsPlainText -Force))

# Caminho do arquivo com a lista de servidores
$serversFilePath = 'C:\Temp\ListaChecagem.txt'

# Caminho do arquivo de log
$logFile = "C:\Temp\StatusCopiaKB.txt"

# Função para escrever no arquivo de log
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logFile -Value ("{0} {1}" -f (Get-Date), $message)
}

# Função para copiar pacotes
function Copy-Packages {
    param (
        [string]$sourcePath,
        [string]$serversFilePath
    )

    # Lê a lista de servidores do arquivo TXT
    $servers = Get-Content -Path $serversFilePath

    foreach ($server in $servers) {
        $tempPath = "\\$server\C$\Temp" #Não é necessário ajustar
        $destinationPath = "$tempPath\CVE-2024-49112\2024-12-WS2012R2" #DestinoArquivos
        $sourcePath = "\\srvwkst02-dc\tools\Gabs\CVE-2024-49112\2024-12-WS2012R2" #OrigemArquivos

        try {
            # Cria a pasta Temp se não existir
            if (-Not (Test-Path -Path $tempPath)) {
                New-Item -Path $tempPath -ItemType Directory | Out-Null
                Write-Log "Pasta Temp criada em $server."
            }

            # Copia os pacotes
            Write-Host "INICIANDO CÓPIA DO PACOTE (KB) PARA O SERVIDOR $($server)." -ForegroundColor Green
            Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse

            # Verifica se a cópia foi bem sucedida
            if (Test-Path -Path $destinationPath) {
                Write-Log "Cópia para $server foi bem sucedida."
                Write-Output "Cópia para $server foi bem sucedida."
            } else {
                throw "A cópia para $server falhou: o diretório de destino não existe."
            }
        } catch {
            Write-Log "Falha ao copiar para $server $_"
            Write-Output "Falha ao copiar para $server $_"
        }
    }
}

Copy-Packages -sourcePath $sourcePath -serversFilePath $serversFilePath
