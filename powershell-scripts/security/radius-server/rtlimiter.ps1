# Configurações ajustáveis
$tempoBusca = (Get-Date).AddMinutes(-5)  # Janela de análise menor para detecção mais rápida
$falhasMinimas = 15                      # Limite de tentativas falhas antes de bloquear
$bloqueioHoras = 4                       # Duração do bloqueio em horas
$logName = "System"                      # Log onde os eventos RADIUS são registrados
$eventID = 13                            # Event ID para falhas de autenticação RADIUS

# Otimização: Usar FilterHashtable para consulta mais rápida no Event Viewer
$filter = @{
    LogName = $logName
    ID = $eventID
    StartTime = $tempoBusca
}
try {    
    $logs = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop    
    if ($logs) {        
        $contagemFalhas = @{}  
        $logs | ForEach-Object {
            $ip = $_.Properties[0].Value
            if ($ip -match '\b(?:\d{1,3}\.){3}\d{1,3}\b') {
                $contagemFalhas[$ip] = ($contagemFalhas[$ip] + 1)
            }
        }       
        foreach ($ip in $contagemFalhas.Keys) {
            if ($contagemFalhas[$ip] -ge $falhasMinimas) {
                $ruleName = "Bloqueio RADIUS $ip"                               
                $ruleExists = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue                
                if (-not $ruleExists) {
                    Write-EventLog -LogName "Application" -Source "NPS" -EventId 201 -EntryType Information -Message "Bloqueando IP $ip por excesso de tentativas RADIUS falhas ($($contagemFalhas[$ip]))"                    
                    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Block -RemoteAddress $ip -Enabled True -Profile Any -Protocol Any -EdgeTraversalPolicy Block                   
                    #Agendar remoção do bloqueio após o tempo configurado
                    $unblockTime = (Get-Date).AddHours($bloqueioHoras)
                    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-Command `"Remove-NetFirewallRule -DisplayName '$ruleName' -ErrorAction SilentlyContinue`""
                    $trigger = New-ScheduledTaskTrigger -Once -At $unblockTime
                    Register-ScheduledTask -TaskName "Unblock RADIUS $ip" -Action $action -Trigger $trigger -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
catch {
    # Registra erro no Event Viewer se algo falhar
    Write-EventLog -LogName "Application" -Source "NPS" -EventId 202 -EntryType Error -Message "Erro no script de proteção RADIUS: $_" -ErrorAction SilentlyContinue
}