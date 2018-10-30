

```powershell
$location = Get-AzureRmLocation | select displayname | Out-GridView -PassThru -Title "Choose a location"
$publisher=Get-AzureRmVMImagePublisher -Location $location.DisplayName | Out-GridView -PassThru -Title "Choose a publisher"
$offer = Get-AzureRmVMImageOffer -Location $location.DisplayName -PublisherName $publisher.PublisherName | Out-GridView -PassThru -Title "Choose an offer"
$sku = Get-AzureRmVMImageSku -Location $location.DisplayName -PublisherName $publisher.PublisherName -Offer $offer.Offer | select SKUS | Out-GridView -PassThru -Title "Choose an SKU"
$title = "SKUs for location: " + $location.DisplayName + ", Publisher: " + $publisher.PublisherName + ", Offer: " + $offer.Offer + ", SKU: " + $sku.Skus

$title
```

