

```powershell
<#Completed @ NPixel Account. No need to excute more.
1. Register-AzureRmProviderFeature -FeatureName ManagedResourcesMove -ProviderNamespace Microsoft.Compute
# wait till "Registering -> Registered"
2. Get-AzureRmProviderFeature -FeatureName ManagedResourcesMove -ProviderNamespace Microsoft.Compute
3. Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute
#>

$Resource = Get-AzureRmResource -ResourceType "Microsoft.Compute/images" -ResourceName "plogstash1-image-20181101120612"
Move-AzureRmResource -ResourceId $Resource.ResourceId -DestinationResourceGroupName "flatformRG-central"

$Resource = Get-AzureRmResource -ResourceType "Microsoft.Compute/images" -ResourceName "nes-master-image-20181101113822"
Move-AzureRmResource -ResourceId $Resource.ResourceId -DestinationResourceGroupName "flatformRG-central"

```

