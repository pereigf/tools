#EXEMPLO UTILIZADO PARA CONSULTA DE SECURITY UPDATES DO MÊS 05-2025 

#O script abaixo pode considerar um pacote de atualização aplicado, mesmo se o sistema operacional está pendente restart, garanta que não exista ambientes com restart pendente, independente do resultado do script.

# Diretório para consulta dos servidores, adicione a lista de computadores no .TXT abaixo para consultar
$Computers = Get-Content -Path 'C:\Temp\ListaChecagem.txt'

# KBs por versao do sistema operacional (atualize conforme o Catálogo da Microsoft)
$ConsultarKBs_2016 = @("KB5058383","KB5058524")  # Windows Server 2016
$ConsultarKBs_2019 = @("KB5058392")  # Windows Server 2019
$ConsultarKBs_2022_21H2 = @("KB5058385")  # Server 2022 (21H2)
$ConsultarKBs_2022_23H2 = @("")  # Server 2022 (23H2)
$ConsultarKBs_2022_Outras = @("KB5058385")  # KBs para outras builds do Server 2022
$ConsultarKBs_Win10_22H2 = @("KB5058379")  # Windows 10 22H2

# Saída do relatório
$outputPath = "C:\Temp\Output\$(Get-Date -f yyyy-MM-dd)-KBs-Consulta-Servidores.txt"
Clear-Content -Path $outputPath -ErrorAction SilentlyContinue

foreach ($computername in $Computers) {
    try {
        #Identificaçao do SO (versao + build)
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername
        $osVersion = $osInfo.Version
        $osCaption = $osInfo.Caption
        $osBuild = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion

        #Definir KBs com base na versao exata
        if ($osVersion.StartsWith("10.0.14393")) {
            $ConsultarKBs = $ConsultarKBs_2016
            $osName = "Windows Server 2016"
        }
        elseif ($osVersion.StartsWith("10.0.17763")) {
            $ConsultarKBs = $ConsultarKBs_2019
            $osName = "Windows Server 2019"
        }
        elseif ($osVersion.StartsWith("10.0.20348")) {
            if ($osBuild -eq "21H2") {
                $ConsultarKBs = $ConsultarKBs_2022_21H2
                $osName = "Windows Server 2022 (21H2)"
            }
            elseif ($osBuild -eq "23H2") {
                $ConsultarKBs = $ConsultarKBs_2022_23H2
                $osName = "Windows Server 2022 (23H2)"
            }
            else {
                $ConsultarKBs = $ConsultarKBs_2022_Outras
                $osName = "Windows Server 2022 (Build $osBuild)"
            }
        }
        elseif ($osVersion.StartsWith("10.0.19045") -and $osCaption -like "*Windows 10*") {
            $ConsultarKBs = $ConsultarKBs_Win10_22H2
            $osName = "Windows 10 22H2"
        }
        else {
            Write-Host "SO nao reconhecido: $computername (Versao: $osVersion | Build: $osBuild)" -ForegroundColor Yellow
            Add-Content -Path $outputPath -Value "$computername - SO nao mapeado - Versao: $osVersion | Build: $osBuild"
            continue
        }

        # 🔎 Verificar cada KB
        foreach ($KB in $ConsultarKBs) {
            if (Get-HotFix -Id $KB -ComputerName $computername -ErrorAction SilentlyContinue) {
                Write-Host "$KB encontrado em $computername ($osName)" -ForegroundColor Green
            }
            else {
                Write-Host "$KB nao encontrado em $computername ($osName)" -ForegroundColor Red
                Add-Content -Path $outputPath -Value "$computername,$KB,$osName"
            }
        }
    }
    catch {
        Write-Host "Falha ao acessar $computername $_" -ForegroundColor Red
        Add-Content -Path $outputPath -Value "$computername,ERRO,$_"
    }
}

Write-Host "Relatorio gerado em: $outputPath" -ForegroundColor Cyan