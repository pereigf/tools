$Username = 'esbr\gabriel.ebs'
$Password = ''
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $pass

$computers = Get-Content -Path 'C:\Temp\Servers_Updates.txt'
$outputFile = "C:\temp\2025-05-SecurityPatchs-HML.csv"
$results = @()

$comando = {
    try {
        $hotfixes = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 6
        $hotfixes | ForEach-Object {
            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                HotFixID = $_.HotFixID.Trim()   # Remove espaços extras e caminhos indesejados
                InstalledOn = if ($_.InstalledOn) { $_.InstalledOn.ToString("yyyy-MM-dd") } else { "Não informado" }  # Formata a data corretamente
                Description = $_.Description
            }
        }
    }
    catch {
        Write-Host "Erro ao obter atualizações em $env:COMPUTERNAME"
    }
}

$computers | ForEach-Object {
    try {
        Write-Host "`nBuscando atualizações em $_..."
        $hotfixes = Invoke-Command -ComputerName $_ -ScriptBlock $comando -Credential $Cred -Verbose
        $results += $hotfixes

        # Exibe os resultados formatados no console
        $hotfixes | Format-Table -AutoSize
    }
    catch {
        Write-Host "Ocorreu um problema ao acessar o ambiente: $_"
    }
}

# Salva os resultados no arquivo CSV com os campos corrigidos
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "Arquivo CSV salvo em $outputFile"