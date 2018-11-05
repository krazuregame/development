<#   
================================================================================ 
 Name: Bulk_VirtualMachines_Creation_CSV.ps1 
 Purpose: Bulk Virtual Machines Creation 
 Author: molee
 Description: This script is for creating Azure VMs from CSV file using Powershell. 
 Limitations/Prerequisite:
    * Before you excute this script, excute "1_Bulk_Infrastructure_Creation_CSV.ps1" file first 
    * Input all the parameters required in VMconfig.csv file   
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
    * Need Slack Application URI (if you don't want to be alerted, just remove slack part from this script)
    * 참고: https://api.slack.com/incoming-webhooks
 ================================================================================ 
#>

$csvpath = import-csv '~\vmconfig.csv'
Foreach ($csv in $csvpath) {
    Start-Job -Name $csv.vmname -ScriptBlock { param ($vmName, $resourceGroup, $nwresourceGroup, $location, $vmSize, $vnetName, $pipname, $nicname, $nsgName, $osdiskname, $AvailabilitySetName, $disksize, $publisher, $offer, $sku, $os, $subnetname, $publicip, $privateip, $customimage, $numdatadisk, $bootdiagresourcegroup, $bootdiagstoragename, $imageresourcegroup, $imagename)

$env = Get-Content -Raw -Path '~\configuration.json' | ConvertFrom-Json

$tenantID = $env.spn.tenantID
$appid = $env.spn.appid
$pwd = Get-Content '~\LoginCred.txt'| ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential($appid, $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal


$createRG = Get-AzureRmResourceGroup -Name $resourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue

if($notPresent)
{
    # Create a resource group
    $createRG = New-AzureRmResourceGroup -Name $resourceGroup -Location $location

}

#Get vNET info.
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $nwresourceGroup -Name $vnetName

#Get NSG info.
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $nwresourceGroup -Name $nsgName


# Create user object
$username = $env.oscred.username
$userpw = $env.oscred.userpw


$secureuserpw = $userpw | ConvertTo-SecureString -AsPlainText -Force
$oscred = New-Object pscredential ($username, $secureuserpw)


if($publicip -eq "y")
{
    # Create a public IP address
    $pipname = $vmname+"-pip"
    $pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name $pipName -AllocationMethod Static
    $pip = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Name $pipName
}
else
{
    $pip = $null
}

#Check if AVS Exists
if($AvailabilitySetName -ne "$null")
{
    $createAS = Get-AzureRMAvailabilitySet -ResourceGroupName $resourcegroup -Name $AvailabilitySetName -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if($notPresent)
    {
        # Create a AVS : Availability Set FD:2/UD:5
        $createAS = New-AzureRmAvailabilitySet -Location $location -Name $AvailabilitySetName -ResourceGroupName $resourceGroup -Sku aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 5
    }

}

#Get AVS info.
$GetAVS = Get-AzureRmAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $resourceGroup
$Subnet=Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -name $subnetname

$nicname = $vmname+"-nic"

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $Subnet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -PrivateIpAddress $privateip
$nic = Get-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $resourcegroup


$osdiskname = $vmname+"-osdisk"

if($customimage -eq "n")
{

        if($os -eq "windows")
        {
            # Create a virtual machine configuration
            $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $GetAVS.Id
            $vmConfig = Set-AzureRmVMSourceImage -VM $vmconfig -PublisherName $publisher -Offer $offer -Skus $sku -Version latest
            $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmconfig -Windows -ComputerName $vmName -Credential $oscred -ProvisionVMAgent
            $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "$osdiskname" -DiskSizeInGB $disksize -CreateOption FromImage -Caching ReadWrite -StorageAccountType Premium_LRS
            $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
            $vmConfig = Set-AzureRmVMBootDiagnostics -VM $VMConfig -Enable -ResourceGroupName $bootdiagresourcegroup -StorageAccountName $bootdiagstoragename
            
            # Create a virtual machine
            New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
            
        }

        if($os -eq "linux")
        {
            # Create a virtual machine configuration
            $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $GetAVS.Id
            $vmConfig = Set-AzureRmVMSourceImage -VM $vmconfig -PublisherName $publisher -Offer $offer -Skus $sku -Version latest
            $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmconfig -Linux -ComputerName $vmName -Credential $oscred
            $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "$osdiskname" -DiskSizeInGB $disksize -CreateOption FromImage -Caching ReadWrite -StorageAccountType Premium_LRS
            $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
            $vmConfig = Set-AzureRmVMBootDiagnostics -VM $VMConfig -Enable -ResourceGroupName $bootdiagresourcegroup -StorageAccountName $bootdiagstoragename
            
            # Create a virtual machine
            New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
        }

}


else
{
      
          if($os -eq "windows")
        {
            $image = Get-AzureRmImage -ImageName $imagename -ResourceGroupName $imageresourcegroup
            $vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmSize -AvailabilitySetId $GetAVS.Id
            $vmConfig = Set-AzureRmVMSourceImage -VM $vmconfig -Id $image.id
            $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -CreateOption FromImage -StorageAccountType Premium_LRS -Name $osdiskname -Caching ReadWrite
            $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmconfig -windows -ComputerName $vmName -Credential $oscred -ProvisionVMAgent
            $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
            
            for($i=0; $i -lt $numdatadisk; $i++){
            $datadiskname = $vmName+"-datadisk"+"-$i"
            $vmConfig = Add-AzureRmVMDataDisk -VM $vmConfig -Name $datadiskname -CreateOption FromImage -StorageAccountType Premium_LRS -Lun $i -Caching ReadOnly
            }

            $vmConfig = Set-AzureRmVMBootDiagnostics -VM $VMConfig -Enable -ResourceGroupName $bootdiagresourcegroup -StorageAccountName $bootdiagstoragename
            
            New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
            
        }

        if($os -eq "linux")
        {
            $image = Get-AzureRmImage -ImageName $imagename -ResourceGroupName $imageresourcegroup
            $vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmSize -AvailabilitySetId $GetAVS.Id
            $vmConfig = Set-AzureRmVMSourceImage -VM $vmconfig -Id $image.id
            $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -CreateOption FromImage -StorageAccountType Premium_LRS -Name $osdiskname -Caching ReadWrite
            $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmconfig -Linux -ComputerName $vmName -Credential $oscred
            $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
            
            for($i=0; $i -lt $numdatadisk; $i++){
            $datadiskname = $vmName+"-datadisk"+"-$i"
            $vmConfig = Add-AzureRmVMDataDisk -VM $vmConfig -Name $datadiskname -CreateOption FromImage -StorageAccountType Premium_LRS -Lun $i -Caching ReadOnly
            }

            $vmConfig = Set-AzureRmVMBootDiagnostics -VM $VMConfig -Enable -ResourceGroupName $bootdiagresourcegroup -StorageAccountName $bootdiagstoragename

            New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
        }

}




} -ArgumentList $csv.vmName, $csv.resourceGroup, $csv.nwresourceGroup, $csv.location, $csv.vmSize, $csv.vnetName, $csv.pipname, $csv.nicname, $csv.nsgName, $csv.osdiskname, $csv.AvailabilitySetName, $csv.disksize, $csv.publisher, $csv.offer, $csv.sku, $csv.os, $csv.subnetname, $csv.publicip, $csv.privateip, $csv.customimage, $csv.numdatadisk, $csv.bootdiagresourcegroup, $csv.bootdiagstoragename, $csv.imageresourcegroup, $csv.imagename

} 




