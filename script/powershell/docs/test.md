

```powershell
$csvpath = import-csv 'C:\Users\molee\Desktop\vminfo.csv'
Foreach ($csv in $csvpath) {
    Start-Job -Name $csv.vmname -ScriptBlock { param ($ResourceGroupName, $NICName)

$env = Get-Content -Raw -Path '~\configuration.json' | ConvertFrom-Json

$tenantID = $env.spn.tenantID
$appid = $env.spn.appid
$pwd = Get-Content '~\LoginCred.txt'| ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential($appid, $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal

$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName `
    -Name $NICName

$nic.EnableAcceleratedNetworking = $true

$nic | Set-AzureRmNetworkInterface

} -ArgumentList $csv.ResourceGroupName, $csv.NICName
}



```

