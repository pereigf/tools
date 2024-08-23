$BuscaUsuarios = Get-aduser -filter * -Properties * | where-object {$_.whenCreated -ge  "01/01/2024"} | ? {$_.extensionAttribute1 -eq $null} | Select SamAccountName -ExpandProperty SamAccountName
                                                                                  #FORMATO DATA: MM/DD/YYYY
$ZABBIX_SERVER_PROXY="10.156.5.20"
$NOME_HOST_ZABBIX="CONTOSO--SRV-WIN-PRD-SRVADS002DCR"
$CHAVE="user_without_ext_attr"

if ($BuscaUsuarios)
{
#Write-Host $BuscaUsuarios
C:\Zabbix\zabbix_sender.exe -z $ZABBIX_SERVER_PROXY -s "$NOME_HOST_ZABBIX" -k $CHAVE -o $BuscaUsuarios
}
else
{
C:\Zabbix\zabbix_sender.exe -z $ZABBIX_SERVER_PROXY -s "$NOME_HOST_ZABBIX" -k $CHAVE -o 0
}