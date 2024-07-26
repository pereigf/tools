Set-DnsClientServerAddress -InterfaceIndex 1 -ServerAddresses ("10.156.10.41","10.156.4.18")

#OU

Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("10.156.10.41","10.156.4.18")