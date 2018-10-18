# Azure Deploy Infrastructure with CSV - PowerShell Example

* Code: https://github.com/krazuregame/development/script/powershell/src/2_1_Bulk_Infrastructure_Creation_CSV.ps1
* CSV 파일 예제 : https://github.com/krazuregame/development/script/powershell/src/Infraconfig.csv


## Scenario Diagram
<img src="../../../images/Infraconfig.png" width="60%" height="60%">



## 예제 설명
CSV 파일의 정보를 읽어들여, 해당 값들에 맞추어 가상머신이 생설될 Infrastructure를 선구성한다.
CSV 파일의 예제를 통해 생성되는 Azure의 리소스들은 다음과 같다.

1. 리소스그룹(Resource Group)
2. 가상네트워크(Virtual Network)
3. 서브넷(Subnet)
4. 네트워크 보안 그룹(Network Security Group)

ResourceGroup | Location | Subnetname | SubnetAddress | vnetname | vnetAddress | nsgname | nsgrulename | port | priority
------------ | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- 
NetworkRG	| Korea Central	| LinuxSubnet	| 10.50.1.0/24	| DemoVnet	| 10.50.0.0/16	| LinuxSSH	| LinuxNSG	| 22	| 1010
NetworkRG	| Korea Central	| WindowsSubnet	| 10.50.2.0/24	| DemoVnet	| 10.50.0.0/16	| WindowsRDP	| WindowsNSG	| 3389	| 1030


## Powershell 코드설명

1. CSV 파일 Import하기 [Docs Link](https://docs.microsoft.com/ko-kr/powershell/module/Microsoft.PowerShell.Utility/Import-Csv?view=powershell-6)

~~~
Import-csv "c:\InfraConfig.csv"
~~~


2. Foreach를 활용한 looping 작업 [Docs Link](https://docs.microsoft.com/ko-kr/powershell/module/Microsoft.PowerShell.Core/ForEach-Object?view=powershell-6)

~~~
$csvpath = Import-csv "c:\InfraConfig.csv"
Foreach ($csv in $csvpath){

         $csv.resourcegroup
         $csv.location
             ...
}
~~~



3. Azure 리소스 그룹 생성 [Docs Link](https://docs.microsoft.com/ko-kr/azure/virtual-network/quick-create-powershell#create-a-virtual-network)


~~~
$csvpath = Import-csv "c:\InfraConfig.csv"
Foreach ($csv in $csvpath){

         New-AzureRmResourceGroup -Name $csv.name -Location $csv.location
}
~~~


4. Azure 가상네트워크 생성 [Docs Link](https://docs.microsoft.com/ko-kr/azure/virtual-network/quick-create-powershell#create-a-virtual-network)


~~~
$csvpath = Import-csv "c:\InfraConfig.csv"
Foreach ($csv in $csvpath){

         New-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Location $csv.location `
         -Name $csv.vnetName -AddressPrefix $csv.vnetAddress
}
~~~


5. Azure 서브넷 생성 [Docs Link](https://docs.microsoft.com/ko-kr/azure/virtual-network/quick-create-powershell#create-a-virtual-network)

~~~
$csvpath = Import-csv "c:\InfraConfig.csv"
Foreach ($csv in $csvpath){
         
         $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $csv.resourcegroup -Name $csv.vnetName 
         Add-AzureRmVirtualNetworkSubnetConfig -Name $csv.subnetName -AddressPrefix $csv.subnetAddress -VirtualNetwork $vnet
         $vnet | Set-AzureRmVirtualNetwork
}
~~~


6. Azure 네트워크보안그룹 생성 [Docs Link](https://docs.microsoft.com/ko-kr/azure/virtual-network/tutorial-filter-network-traffic-powershell)

~~~
$csvpath = Import-csv "c:\InfraConfig.csv"
Foreach ($csv in $csvpath){

    New-AzureRmNetworkSecurityGroup -name $csv.nsgName -ResourceGroupName $csv.resourcegroup -Location $csv.location 
    ...
    Add-AzureRmNetworkSecurityRuleConfig -Name $csv.nsgRuleName -Access Allow -Protocol Tcp -Direction Inbound -Priority $csv.priority -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange $csv.port
    ... 
    Set-AzureRmNetworkSecurityGroup
    
}
~~~



