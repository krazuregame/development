$tenantID = "************************"
$appid = "************************"
$pwd = Get-Content c:\LoginCred.txt| ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal