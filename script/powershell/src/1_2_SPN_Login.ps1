<#   
================================================================================ 
 Name: SPN_Longin.ps1 
 Purpose: Login Azure Subscription with SPN 
 Author: molee
 Description: This script is for logining Azure with Service Principal Credential you made. 
 Limitations/Prerequisite:
    * Login with the credential(txt file) you created
    * need Application ID you created.
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
 ================================================================================ 
#>


$tenantID = "*************************"
$appid = "*************************"
$pwd = Get-Content c:\LoginCred.txt| ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal