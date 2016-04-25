$ipv4adr = (get-netipaddress -InterfaceAlias 'Ethernet 2' -AddressFamily IPv4).IPAddress
$ipv4gw ="192.168.1.1"
$prefix = "16"
$alias = "Ethernet 2"

#remove-netipaddress -InterfaceAlias 'Ethernet 2' -AddressFamily IPv4 -Confirm:$false
# $netadapter = Get-NetAdapter -Name 'Ethernet 2';
#New-NetIPAddress -AddressFamily IPv4 -IPAddress $ipv4adr -DefaultGateway $ipv4gw -PrefixLength $prefix -Confirm:$false -InterfaceAlias $alias

$ipv4dns1 = (get-netipaddress -InterfaceAlias 'Ethernet 2' -AddressFamily IPv4).IPAddress
# $ipv4dns2 = "192.168.90.110" #uncomment and set for two DNS servers
Get-DnsClientServerAddress -InterfaceAlias $alias | Set-DnsClientServerAddress -ResetServerAddresses
Set-DNSClientServerAddress -InterfaceAlias $alias -ServerAddresses 192.168.1.11
# Set-DNSClientServerAddress -InterfaceAlias $alias -ServerAddresses ("$ipv4dns1","$ipv4dns2") #use this for two dns servers