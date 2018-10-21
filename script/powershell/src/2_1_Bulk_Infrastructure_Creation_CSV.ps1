<#   
================================================================================ 
 Name: Infrastructure_Creation_CSV.ps1 
 Purpose: Azure Infrastructure Creation 
 Author: molee
 Description: This script is for creating Azure infrastructure from CSV file using Powershell. 
 Limitations/Prerequisite:
    * Need Azure Service Principal Credential to login your subscription
      -> You can use "0_Create_SPN.PS1" file to create SPN if you don't have any.
    * Input all the parameters required in "Infraconfig.csv" file providing together
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
 ================================================================================ 
#>



$tenantID = "*************************"
$appid = "*************************"
$pwd = Get-Content 'C:\LoginCred.txt' | ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal

$csvpath= @()
$csvpath = import-csv 'C:\Infraconfig.csv'

Foreach ($csv in $csvpath) {

#Check if RG Exists
$createRG = Get-AzureRmResourceGroup -Name $csv.resourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a resource group
    $createRG = New-AzureRmResourceGroup -Name $csv.resourceGroup -Location $csv.location

}


#Check if vNET Exists

if($csv.vnetName -ne "$null" -AND $csv.vnetAddress -ne "$null")
{
    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Name $csv.vnetName -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if($notPresent)
    {
        # Create a vNET
        $vnet = New-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Location $csv.location -Name $csv.vnetName -AddressPrefix $csv.vnetAddress
    }
}


if($csv.vnetNam -ne "$null" -AND $csv.subnetname -ne "$null")
{
    #Check if Subnet Exists
    $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Name $csv.vnetName 
    $subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name $csv.subnetName -VirtualNetwork $vnet -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if($notPresent)
    {
        # Create a subnet configuration
        $subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig -Name $csv.subnetName -AddressPrefix $csv.subnetAddress -VirtualNetwork $vnet
        $vnet | Set-AzureRmVirtualNetwork
    }

}


#Check if NSG group Exists

if($csv.nsgname -ne "$null")
{
    $nsg = Get-AzureRmNetworkSecurityGroup -Name $csv.nsgName -ResourceGroupName $csv.resourcegroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if($notPresent)
    {
        # Create a NSG group
        $nsg = New-AzureRmNetworkSecurityGroup -name $csv.nsgName -ResourceGroupName $csv.resourcegroup -Location $csv.location 
    }
}

if($csv.nsgname -ne "$null" -AND $csv.nsgRulename -ne "$null")
{
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

} 


