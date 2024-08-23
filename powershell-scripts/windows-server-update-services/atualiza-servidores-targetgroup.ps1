# Importa o módulo do WSUS
Import-Module UpdateServices

# Conecta ao servidor WSUS
$Server = 'hostnameservidordewsus'
$Port = 8531
$UseSsl = $true
$wsus = Get-WsusServer -Name $Server -PortNumber $Port -UseSsl:$UseSsl

# Obtém o grupo de destino específico
$targetGroup = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq "AD-DNS-CA" }

# Obtém todas as máquinas dentro do grupo de destino
$computers = $targetGroup.GetComputerTargets()

# Executa o comando em cada máquina
foreach ($computer in $computers) {
    $computerName = $computer.FullDomainName
    Write-Output "Atualizando $computerName"
    
    # Executa o comando psexec em cada máquina
    Start-Process -FilePath "psexec.exe" -ArgumentList "-s -i \\$computer powershell.exe -command Install-WindowsUpdate -AcceptAll -Install -AutoReboot" -WindowStyle Hidden
    Start-Process -FilePath "psexec.exe" -ArgumentList "-s -i \\$computer powershell.exe -command usoclient ScanInstallWait" -WindowStyle Hidden
    
    
    Start-Sleep(10)
}
