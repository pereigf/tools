$Computadores = Get-Content -Path 'C:\Temp\Servers_WSUS.txt'
$Intervalo = 60  # Intervalo de envio da tecla NumLock (em segundos)
$DisparoAtualizacao = Powershell.exe -command Install-WindowsUpdate -AcceptAll -verbose -AutoReboot

# Função para simular a tecla NumLock (ANTILOGOFF)
function SimularTeclaNumLock {
    [System.Windows.Forms.SendKeys]::SendWait("{NUMLOCK}")
}
#### Timer para enviar a tecla NumLock periodicamente (ANTILOGOFF)
$Timer = New-Object System.Timers.Timer
$Timer.Interval = $Intervalo * 1000  # Convertendo para milissegundos
$Timer.AutoReset = $true
$Timer.Enabled = $true
$Timer.add_Elapsed({
    SimularTeclaNumLock
})

foreach ($Computador in $Computadores) {

    if (Test-Connection -ComputerName $Computador -Count 1 -Quiet) {
        Write-Host ""
        Write-Host "Conectado ao computador $Computador" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Não foi possível conectar-se ao computador $Computador"
        Write-Host ""
        continue
    }

            if ($DisparoAtualizacao -match "VERBOSE:") {
            Write-Host "Disparo de atualizações lançado com sucesso em $Computador" -ForegroundColor Green
            Write-Host ""
            Start-Sleep(60)
            Write-Host "Iniciado processo de reincialização em $Computador" -ForegroundColor Cyan
            Restart-Computer -ComputerName $Computador -Force
        } else {
            Write-Warning "Falha no primeiro disparo de atualizações em $Computador"
            Write-Host "$Computador Falha no processo de reinicialização $_" -ForegroundColor DarkRed
            Write-Host ""
        } 
}
# Encerra o timer após o processamento de todos os computadores
$Timer.Stop()
$Timer.Dispose()