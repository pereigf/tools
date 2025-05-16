<#
.SYNOPSIS
Configura os protocolos TLS no sistema Windows e ajusta as configurações relacionadas do .NET Framework.

.DESCRIPTION
Este script habilita o TLS 1.2 e desabilita os protocolos TLS 1.0 e 1.1 no SCHANNEL do Windows.
Também configura as chaves de registro do .NET Framework para usar criptografia forte.

.PARAMETER DisableLegacyTls
Desabilita os protocolos TLS 1.0 e 1.1.

.PARAMETER EnableTls12
Habilita o protocolo TLS 1.2.

.PARAMETER WhatIf
Mostra o que seria feito sem realmente executar as alterações.

.EXAMPLE
.\Configure-TLS.ps1 -DisableLegacyTls -EnableTls12
Configura o sistema para usar apenas TLS 1.2.

.EXAMPLE
.\Configure-TLS.ps1 -DisableLegacyTls -EnableTls12 -WhatIf
Mostra o que seria feito sem realmente fazer as alterações.
#>
param (
    [switch]$DisableLegacyTls,
    [switch]$EnableTls12,
    [switch]$WhatIf
)

begin {
    # Função para verificar se um valor de registro já está configurado corretamente
    function Test-RegistryValue {
        param (
            [string]$Path,
            [string]$Name,
            [int]$ExpectedValue
        )
        
        if (-Not (Test-Path $Path)) {
            return $false
        }
        
        $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $currentValue) {
            return $false
        }
        
        return ($currentValue.$Name -eq $ExpectedValue)
    }

    # Função para criar ou atualizar uma chave de registro
    function Set-RegistryValue {
        param (
            [string]$Path,
            [string]$Name,
            [int]$Value,
            [string]$Description
        )
        
        $action = "Setting"
        $alreadySet = Test-RegistryValue -Path $Path -Name $Name -ExpectedValue $Value
        
        if ($alreadySet) {
            Write-Host "[OK]    $Description is already correctly configured."
            return
        }
        
        if ($WhatIf) {
            Write-Host "[WHATIF] Would $action $Description"
            return
        }
        
        try {
            if (-Not (Test-Path $Path)) {
                Write-Host "[INFO]  Creating registry path: $Path"
                $null = New-Item -Path $Path -Force -ErrorAction Stop
            }
            
            Write-Host "[CONFIG] $action $Description"
            New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host "[ERROR] Failed to configure $Description`: $_" -ForegroundColor Red
        }
    }
}

process {
    # Configurações do TLS
    if ($DisableLegacyTls) {
        Write-Host "`nConfiguring Legacy TLS protocols (1.0 and 1.1)..." -ForegroundColor Cyan

        # TLS 1.0 Client
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" `
                         -Name "DisabledByDefault" -Value 1 `
                         -Description "TLS 1.0 Client: DisabledByDefault"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" `
                         -Name "Enabled" -Value 0 `
                         -Description "TLS 1.0 Client: Disabled"

        # TLS 1.0 Server
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" `
                         -Name "DisabledByDefault" -Value 1 `
                         -Description "TLS 1.0 Server: DisabledByDefault"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" `
                         -Name "Enabled" -Value 0 `
                         -Description "TLS 1.0 Server: Disabled"

        # TLS 1.1 Client
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" `
                         -Name "DisabledByDefault" -Value 1 `
                         -Description "TLS 1.1 Client: DisabledByDefault"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" `
                         -Name "Enabled" -Value 0 `
                         -Description "TLS 1.1 Client: Disabled"

        # TLS 1.1 Server
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" `
                         -Name "DisabledByDefault" -Value 1 `
                         -Description "TLS 1.1 Server: DisabledByDefault"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" `
                         -Name "Enabled" -Value 0 `
                         -Description "TLS 1.1 Server: Disabled"

        if (-not $WhatIf) {
            Write-Host "Legacy TLS 1.0 and 1.1 have been disabled." -ForegroundColor Green
        }
    }

    if ($EnableTls12) {
        Write-Host "`nConfiguring TLS 1.2..." -ForegroundColor Cyan

        # TLS 1.2 Server
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" `
                         -Name "Enabled" -Value 1 `
                         -Description "TLS 1.2 Server: Enabled"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" `
                         -Name "DisabledByDefault" -Value 0 `
                         -Description "TLS 1.2 Server: Not DisabledByDefault"

        # TLS 1.2 Client
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" `
                         -Name "Enabled" -Value 1 `
                         -Description "TLS 1.2 Client: Enabled"
        
        Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" `
                         -Name "DisabledByDefault" -Value 0 `
                         -Description "TLS 1.2 Client: Not DisabledByDefault"

        if (-not $WhatIf) {
            Write-Host "TLS 1.2 has been enabled." -ForegroundColor Green
        }
    }

    # Configurações do .NET Framework
    $netFrameworkSettings = @(
        @{
            Path = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727'
            Name = 'SystemDefaultTlsVersions'
            Value = 1
            Description = '.NET 2.0 (32-bit): SystemDefaultTlsVersions'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727'
            Name = 'SystemDefaultTlsVersions'
            Value = 1
            Description = '.NET 2.0 (64-bit): SystemDefaultTlsVersions'
        },
        @{
            Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319'
            Name = 'SystemDefaultTlsVersions'
            Value = 1
            Description = '.NET 4.0 (32-bit): SystemDefaultTlsVersions'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'
            Name = 'SystemDefaultTlsVersions'
            Value = 1
            Description = '.NET 4.0 (64-bit): SystemDefaultTlsVersions'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727'
            Name = 'SchUseStrongCrypto'
            Value = 1
            Description = '.NET 2.0 (32-bit): SchUseStrongCrypto'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727'
            Name = 'SchUseStrongCrypto'
            Value = 1
            Description = '.NET 2.0 (64-bit): SchUseStrongCrypto'
        },
        @{
            Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319'
            Name = 'SchUseStrongCrypto'
            Value = 1
            Description = '.NET 4.0 (32-bit): SchUseStrongCrypto'
        },
        @{
            Path = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319'
            Name = 'SchUseStrongCrypto'
            Value = 1
            Description = '.NET 4.0 (64-bit): SchUseStrongCrypto'
        }
    )

    Write-Host "`nConfiguring .NET Framework settings..." -ForegroundColor Cyan
    foreach ($setting in $netFrameworkSettings) {
        Set-RegistryValue @setting
    }
}

end {
    if (-not $WhatIf) {
        Write-Host "`nConfiguration completed successfully." -ForegroundColor Green
        Write-Host "Note: Some changes may require a reboot to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nWhatIf operation completed. No changes were made." -ForegroundColor Cyan
    }
}