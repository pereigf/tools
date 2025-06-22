
# Script para instalar o módulo PSWindowsUpdate caso não esteja disponível
$comando = {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Instalando o módulo PSWindowsUpdate..."
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber
    }

    # Importa o módulo e executa a atualização
    Import-Module PSWindowsUpdate
    Install-WindowsUpdate -AcceptAll -AutoReboot
}

$computers = Get-Content -Path 'C:\Temp\Servers_Updates.txt'

$computers | foreach {
    try {
        (Invoke-Command -ComputerName $_ -ScriptBlock $comando -Verbose)
    }
    catch {
        Write-Host "Ocorreu um problema com o ambiente: $_"
    }
}