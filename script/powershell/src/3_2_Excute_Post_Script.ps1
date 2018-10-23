<#   
================================================================================ 
 Name: Excute_Post_Script.ps1 
 Purpose: Post Script Excution Using Azure VM Extension 
 Author: molee
 Description: This script is for excuting a post(custom) script using Azure VM extension & Powershell. 
 Limitations/Prerequisite:
    * Need "VMconfig.csv" file for servernames
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure ModuleQ
 ================================================================================ 
#>


#Storage Account has script for post-script
#Powershell(Windows) URL: https://**********.blob.core.windows.net/scripts/InitialScriptWindows.ps1
#Bash Script(Linux) URL: https://**********.blob.core.windows.net/scripts/InitialScriptLinux.sh
          
#Linux Extension - https://docs.microsoft.com/ko-kr/azure/virtual-machines/extensions/custom-script-linux
#Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name $linuxscriptName -Publisher "Microsoft.Azure.Extensions" -Type "customScript" `
#-TypeHandlerVersion 2.0 -Settings $linuxSettings -ProtectedSettings $linuxProtectedSettings            

#Windows Extension - https://docs.microsoft.com/ko-kr/azure/virtual-machines/extensions/custom-script-windows
#Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name $winscriptName -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" `
#-TypeHandlerVersion 1.9 -Settings $winSettings -ProtectedSettings $winProtectedSettings    

$csvpath = import-csv '~\VMconfig.csv'
foreach ($csv in $csvpath){
    Start-Job -Name $csv.vmName { 
        param ($vmName, $resourceGroup, $location, $os) 

        $env = Get-Content -Raw -Path '~\configuration.json' | ConvertFrom-Json

        $tenantID = $env.spn.tenantID
        $appid = $env.spn.appid
        $pwd = Get-Content ~\LoginCred.txt| ConvertTo-SecureString
        $cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
        Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal

        $storageAccountName = $env.blob.storageAccountName
        $storageAccountKey = $env.blob.storageAccountKey

        #Shell
        $linuxuri = $env.blob.linuxuri
        $linuxSettings = @{"fileUris" = @($linuxuri); "commandToExecute" = "./InitialScriptLinux.sh"}
        $linuxProtectedSettings = @{"storageAccountName" = $storageAccountName; "storageAccountKey" = $storageAccountKey}
        $linuxscriptName = "Post-Script-Linux"

        #PS1
        $winuri = $env.blob.winuri
        $winSettings = @{"fileUris" = @($winuri); "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File InitialScriptWindows.ps1"}
        $winProtectedSettings = @{"storageAccountName" = $storageAccountName; "storageAccountKey" = $storageAccountKey}
        $winscriptName = "Post-Script-Windows"
                 
        $status = "$null"

        if($os -eq "linux")
        {
            Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name $linuxscriptName -Publisher "Microsoft.Azure.Extensions" -Type "customScript" `
                                   -TypeHandlerVersion 2.0 -Settings $linuxSettings -ProtectedSettings $linuxProtectedSettings
                                   
            $status = Get-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $linuxscriptName     
               
        }
        
       
        if($os -eq "windows")
        {
            Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name $winscriptName -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" `
                                   -TypeHandlerVersion 1.9 -Settings $winSettings -ProtectedSettings $winProtectedSettings
                                   
            $status = Get-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $winscriptName           
        }
       
       

    } -ArgumentList $csv.vmName, $csv.resourceGroup, $csv.location, $csv.os

}



#REMOVE VM EXTENSION
#Remove-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $scriptName


