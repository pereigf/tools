# Nome dos serviços que você deseja monitorar
$servico1 = "NomeDoServico1"
$servico2 = "NomeDoServico2"

# Função para verificar e iniciar o serviço, se necessário
function VerificarESubirServico {
    param (
        [string]$servico
    )

    $statusServico = Get-Service -Name $servico

    if ($statusServico.Status -ne 'Running') {
        Start-Service -Name $servico
        Write-Output "Serviço $servico iniciado."
    } else {
        Write-Output "Serviço $servico já está em execução."
    }
}

# Verifica o status dos serviços
VerificarESubirServico -servico $servico1
VerificarESubirServico -servico $servico2
