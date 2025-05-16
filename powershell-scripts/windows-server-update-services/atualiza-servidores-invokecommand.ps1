$Username = 'contoso\user'
$Password = ''
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

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
        (Invoke-Command -ComputerName $_ -ScriptBlock $comando -Credential $Cred -Verbose)
    }
    catch {
        Write-Host "Ocorreu um problema com o ambiente: $_"
    }
}