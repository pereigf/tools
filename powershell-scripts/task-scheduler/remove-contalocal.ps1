# Obter todas as contas locais
$localUsers = Get-LocalUser

# Filtrar e remover contas locais que contenham "lenovo", "tmp" ou "temp" no nome
$localUsers | Where-Object { $_.Name -match "lenovo|tmp|temp" } | ForEach-Object {
    Write-Host "Removendo conta local: $($_.Name)"
    Remove-LocalUser -Name $_.Name
}
