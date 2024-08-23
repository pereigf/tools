$Computers = Get-Content -Path 'C:\Temp\Servers_WSUS.txt'
$Intervalo = 60  # Intervalo de envio da tecla NumLock (em segundos)

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
$Computers | foreach -Parallel {

    
    try {
        
                        psexec.exe -s -i \\$_ powershell.exe -command  Install-WindowsUpdate -AcceptAll -Install -AutoReboot #> "\\SRVWKST02-DC.ambiental.corp\Tools\Gabs\TesteWsus.log"
                        
    }
    catch { "Ocorreu um problema com o ambiente" + $_ }
     #Write-Host $_   a
}
