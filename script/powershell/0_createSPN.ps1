#Login Azure account using ID/PW
Login-AzureRmAccount

#Set a subscription info. you want to use
$id = Get-AzureRmSubscription -SubscriptionId ************************

#Print the subscription info.
$id.Name
$id.SubscriptionId
$id.TenantId

#Set AD app credential / Info.
Add-Type -Assembly System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(16,3)

$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\LoginCred.txt"
$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force

$spn = "login_cred_moonsun"
$homepage = "http://localhost/$spn"
$identifierUri = $homepage

#$azureAdApplication = New-AzureRmADApplication -DisplayName $spn -HomePage $homepage -IdentifierUris $identifierUri -Password $securepassword 
$azureAdApplication = New-AzureRmADApplication -DisplayName $spn -IdentifierUris $identifierUri -Password $securepassword 


#Set Ad app id just made
$appid = $azureAdApplication.ApplicationId

#Create a AD SP with the AD app
$azurespn = New-AzureRmADServicePrincipal -ApplicationId $appid

#Set AD SP info.
$spnname = $azurespn.ServicePrincipalNames
$spnRole = "Contributor"

#Create a SP Role
New-AzureRmRoleAssignment -RoleDefinitionName $spnRole -ServicePrincipalName $appId

$cred = New-object System.Management.Automation.PSCredential($appId.Guid, $securepassword)

#Login using SPN with (App ID / App PW)
Add-AzureRmAccount -Credential $cred -TenantId $id.TenantId -ServicePrincipal


