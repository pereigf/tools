$dnsName = $env:COMPUTERNAME
$certExists = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Subject -like "*CN=$dnsName*" }

if ($certExists) {
    Write-Output "Certificado já existe para o DNS: $dnsName. Nenhum novo certificado será gerado."
} else {
    Get-Certificate -Template 'Machine' -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName $dnsName
    Write-Output "Novo certificado gerado para o DNS: $dnsName."
}