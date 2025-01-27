<#
'CVE-2013-3900 WinVerifyTrust Signature Validation Vulnerability
'https://learn.microsoft.com/en-us/answers/questions/1182542/cve-2013-3900-winverifytrust-signature-validation
'------------------------------------------------------------------------------------
'
'1. Execute o script abaixo no Powershell como Administrador
'2. Abra o regedit e siga o caminho completo das chaves que foram criadas abaixo, valide se as chaves foram criadas.
#>

If (-Not (Test-Path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config')) {
    New-Item 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config' -Force | Out-Null
}
New-ItemProperty -path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config' -name 'EnableCertPaddingCheck' -value '1' -PropertyType 'DWORD' -Force | Out-Null

If (-Not (Test-Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config')) {
    New-Item 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -Force | Out-Null
}
New-ItemProperty -path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -name 'EnableCertPaddingCheck' -value '1' -PropertyType 'DWORD' -Force | Out-Null
