<#   
================================================================================ 
 Name: Export_VMs_Info_CSV.ps1 
 Purpose: Export all VMs info from Azure Subscription 
 Author: molee
 Description: This script is for exporting all Azure VMs information to CSV file using Powershell. 
 Limitations/Prerequisite:
    * Modify last line for output file path  
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
 ================================================================================ 
#>


#Login with Context
Login-AzureRmAccount

<#Or SPN Login
$tenantID = "*************************"
$appid = "*************************"
$pwd = Get-Content 'C:\LoginCred.txt' | ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal
#>


$vms = Get-AzureRmVM 
$obj = @()

foreach ($vm in $vms){
   

    $vmname = $vm.Name
    $resourceGroupName = $vm.ResourceGroupName
    $location = $vm.Location
    $vmsize = $vm.HardwareProfile.VmSize
    
    $AvailabilitySet = "No"
    if($vm.AvailabilitySetReference -ne $null)
    {
        $AvailabilitySet = $vm.AvailabilitySetReference.id.Split("/")[-1]
    }


    $nicname= $vm.NetworkProfile.NetworkInterfaces.id.Split("/")[-1]
    $nic = Get-AzureRmNetworkInterface -name $nicname -ResourceGroupName $Vm.ResourceGroupName -ErrorAction SilentlyContinue


    $dip = $nic.IPConfigurations.PrivateIpAddress

    $pip = "No"
    if($nic.IPConfigurations.PublicIpAddress -ne $null)
    {
        $pipname = $nic.IPConfigurations.PublicIpAddress.Id.Split("/")[-1]
        $pip = (Get-AzureRmPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -name $pipname).IpAddress
    }
   

    $vnetname = $nic.IpConfigurations.subnet.id.split("/")[-3]
    $subnetname = $nic.IpConfigurations.subnet.id.split("/")[-1]
    
    $nsgname = "none"
    if($nic.NetworkSecurityGroup -ne $null)
    {
        $nsgname = $nic.NetworkSecurityGroup.Id.Split("/")[-1]
    }
    

    $ANstatus = $nic.EnableAcceleratedNetworking

    if($ANstatus -eq $false){$ANstatus = "No"}
    else{$ANstatus = "Yes"}
    
    $pipFQDN = (Get-AzureRmPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -name $pipname).DnsSettings.Fqdn
    if($pipFQDN -eq $null){$pipFQDN = "No"}

    $BootDiagnostic = $BootDiagnosticName = "none"
    if($vm.DiagnosticsProfile.BootDiagnostics.StorageUri -ne $null)
    {
        $BootDiagnostic = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri
        $BootDiagnosticName = $vm.DiagnosticsProfile.BootDiagnostics.StorageUri.replace("https://","").split(".")[0]
    }

    $obj += [PSCustomObject]@{ 

        VMName = $vmname
        ResourceGroupName = $resourceGroupName
        Location = $location
        VMsize = $vmsize
        AvailabilitySet = $AvailabilitySet
        PIP = $pip
        PIPFQDN = $pipFQDN
        DIP = $dip
        vNET = $vnetname
        SubNet = $subnetname
        NICName = $nicname
        NSGName = $nsgname
        ANStatus = $ANStatus
        BootDiagName = $BootDiagnosticName
     }

}

$obj | Export-Csv -append -Path C:\Users\molee\Desktop\vminfo.csv -Encoding UTF8 -NoTypeInformation 
