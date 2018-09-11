$tenantID = "************************"
$appid = "************************"
$pwd = Get-Content 'c:\LoginCred.txt' | ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal


$csvpath = import-csv 'C:\Infraconfig.csv'

Foreach ($csv in $csvpath) {

#Check if RG Exists
$createRG = Get-AzureRmResourceGroup -Name $csv.resourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a resource group
    $createRG = New-AzureRmResourceGroup -Name $csv.resourceGroup -Location $csv.location

}

#Check if AVS Exists
$createAS = Get-AzureRMAvailabilitySet -ResourceGroupName $csv.resourcegroup -Name $csv.AvailabilitySetName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a AVS : Availability Set FD:2/UD:5
    $createAS = New-AzureRmAvailabilitySet -Location $csv.location -Name $csv.AvailabilitySetName -ResourceGroupName $csv.resourceGroup -Sku aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5

}


#Check if vNET Exists
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Name $csv.vnetName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a vNET
    $vnet = New-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Location $csv.location -Name $csv.vnetName -AddressPrefix $csv.vnetAddress

}


#Check if Subnet Exists
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Name $csv.vnetName 
$subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name $csv.subnetName -VirtualNetwork $vnet -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a subnet configuration
    $subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig -Name $csv.subnetName -AddressPrefix $csv.subnetAddress -VirtualNetwork $vnet
    $vnet | Set-AzureRmVirtualNetwork
}



#Check if NSG group Exists
$nsg = Get-AzureRmNetworkSecurityGroup -Name $csv.nsgName -ResourceGroupName $csv.resourcegroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a NSG group
    $nsg = New-AzureRmNetworkSecurityGroup -name $csv.nsgName -ResourceGroupName $csv.resourcegroup -Location $csv.location 

}


#Check if NSG Rule Exists
$nsg = Get-AzureRmNetworkSecurityGroup -Name $csv.nsgName -ResourceGroupName $csv.resourcegroup
$nsgRule = $nsg | Get-AzureRmNetworkSecurityRuleConfig -Name $csv.nsgRuleName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Add a NSG Rule @ NSG
    $nsgRule = $nsg | Add-AzureRmNetworkSecurityRuleConfig -Name $csv.nsgRuleName -Description "Allow Inbound" -Access Allow -Protocol Tcp -Direction Inbound -Priority $csv.priority `
    -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange $csv.port | Set-AzureRmNetworkSecurityGroup

}


} 


