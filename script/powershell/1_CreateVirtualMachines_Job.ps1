$csvpath = import-csv 'C:\VMconfig.csv'
Foreach ($csv in $csvpath) {
    Start-Job -Name $csv.vmname -ScriptBlock { param ($vmName, $resourceGroup, $location, $vmSize, $vnetName, $pipname, $nicname, $nsgName, $osdiskname, $AvailabilitySetName, $disksize, $publisher, $offer, $sku, $os)

#Login /w SPN   
$tenantID = "************************"
$appid = "************************"
$pwd = Get-Content 'C:\LoginCred.txt' | ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal


#Get vNET info.
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetName

#Get NSG info.
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Name $nsgName


# Create user object
$username = 'azureadmin'
$userpw = 'Password@123'
$secureuserpw = $userpw | ConvertTo-SecureString -AsPlainText -Force
$oscred = New-Object pscredential ($username, $secureuserpw)

# Create a public IP address
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name $pipName -AllocationMethod Static
$pip = Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Name $pipName

#Get AVS info.
$GetAVS = Get-AzureRmAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $resourceGroup

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id



if($os -eq "windows")
{
    # Create a virtual machine configuration
    $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $GetAVS.Id
    $vmConfig = Set-AzureRmVMSourceImage -VM $vmconfig -PublisherName $publisher -Offer $offer -Skus $sku -Version latest
    $vmConfig = Set-AzureRmVMOperatingSystem -VM $vmconfig -Windows -ComputerName $vmName -Credential $oscred -ProvisionVMAgent
    $vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "$osdiskname" -DiskSizeInGB $disksize -CreateOption FromImage -Caching ReadWrite -StorageAccountType Premium_LRS
    $vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id
    
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

    # Create a virtual machine
    New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
}

# Get VM status for Slack alert
$vmstatus = Get-AzureRmVM -ResourceGroupName "$resourceGroup" -Name "$vmName" -Status
$displaystatus = $vmstatus.Statuses[1].DisplayStatus
$getdate = Get-Date

# Notification to slack
if($vmstatus.Statuses[0].Code -eq "ProvisioningState/succeeded")
    {
        Write-Host "'$vmName' Creation is Succeeded. Just notificated to Slack channel!"
        
        $payload = 
        @{
            "text" = "'$vmName' is successfully created :) `n Status: $displaystatus `n Time: $getdate"
        }
 
       $webhook = Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri "https://hooks.slack.com/services/**************"
    }
else
    {
         Write-Host "'$vmName' Creation is failed. Just notificated to Slack channel!"
        
        $payload = 
        @{
            "text" = "'$vmName' creation is failed :( `n Status: $displaystatus `n Time: $getdate"
        }
 
       $webhook = Invoke-WebRequest -UseBasicParsing `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -Uri "https://hooks.slack.com/services/**************"


    }


} -ArgumentList $csv.vmName, $csv.resourceGroup, $csv.location, $csv.vmSize, $csv.vnetName, $csv.pipname, $csv.nicname, $csv.nsgName, $csv.osdiskname, $csv.AvailabilitySetName, $csv.disksize, $csv.publisher, $csv.offer, $csv.sku, $csv.os

} 

