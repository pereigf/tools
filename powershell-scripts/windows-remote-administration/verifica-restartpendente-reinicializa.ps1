$Computers = Get-Content -Path 'C:\Temp\Servers_PendenteRestart.txt'
#$RebootPendingComputers = @()

$Computers | ForEach-Object {
    try {
        $result = Test-PendingReboot -ComputerName $_ -SkipConfigurationManagerClientCheck
        #if ($result.IsRebootPending) {
        if ($result.IsRebootPending -eq $true) {
            #$RebootPendingComputers += $_
            Write-Host "O ambiente $_ está pendente restart, realizando reinicialização.." -ForegroundColor Cyan
            Write-Host ""
            Restart-Computer -ComputerName $_ -Force
            Start-Sleep(60)
        }else
        {

        Write-Host "O ambiente $_ não está pendente restart, prosseguindo."

       }
    }
    catch {
        "Ocorreu um problema com o ambiente: " + $_
    }
}

# Exportar relatório para arquivo .txt
$RebootPendingComputers | Out-File -FilePath 'C:\Temp\Output\PendenteRestart.txt'

# Exibir resultado no console
if ($RebootPendingComputers.Count -gt 0) {
    Write-Host "Computadores com pendência de reinicialização:"
    Write-Host ""
    $RebootPendingComputers | ForEach-Object { Write-Host $_ }
} else {
    Write-Host ""
    Write-Host "Nenhum computador com pendência de reinicialização." -ForegroundColor Green
}
Write-Host ""
Write-Host "Relatório exportado para C:\Temp\Output\PendenteRestart.txt" -ForegroundColor Cyan
