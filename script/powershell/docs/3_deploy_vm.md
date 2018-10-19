# Deploy Azure VMs using CSV - PowerShell Example

* Code: [Link](https://github.com/krazuregame/development/blob/master/script/powershell/src/2_2_Bulk_VirtualMachines_Creation_CSV.ps1)
* CSV 파일 예제 : [Link](https://github.com/krazuregame/development/blob/master/script/powershell/src/vmconfig.csv)


## 예제 설명
CSV 파일의 정보를 읽어들여, 해당 값들에 맞추어 생성한 Infrastructure 위에 가상머신을 생성한다.
CSV 파일의 예제를 통해 생성되는 Azure의 리소스들은 다음과 같다.

1. 리소스그룹(Resource Group)
2. 공용 IP(Public IP)
3. 네트워크인터페이스카드(NIC)
4. 디스크(OS Disk)
5. 가용성집합(Availability Set)
6. 가상머신(Virtual Machine)


vmname | resourcegroup | location | vmsize | nwresourceGroup | vnetName | subnetName | pipName | nicname | nsgname | osdiskname | disksize | os | publisher | offer | sku | AvailabilitySetName
------------ | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | -------------
Linux-01 | LinuxRG | Korea Central | Standard_DS2_v2 | NetworkRG | DemoVnet | LinuxSubnet | Linux-01-pip | Linux-01-nic | LinuxNSG | Linux-01-disk | 127 | linux | OpenLogic | CentOS | 7.3 | LinuxAVS
Linux-02 | LinuxRG | Korea Central | Standard_DS2_v2 | NetworkRG | DemoVnet | LinuxSubnet | Linux-02-pip | Linux-02-nic | LinuxNSG | Linux-02-disk | 127 | linux | OpenLogic | CentOS | 7.3 | LinuxAVS
Windows-01 | WindowsRG | Korea Central | Standard_DS2_v2 | NetworkRG | DemoVnet | WindowsSubnet | Windows-01-pip | Windows-01-nic | WindowsNSG | Windows-01-disk | 127 | windows | MicrosoftWindowsServer | WindowsServer | 2016-Datacenter | WindowsAVS
Windows-02 | WindowsRG | Korea Central | Standard_DS2_v2 | NetworkRG | DemoVnet | WindowsSubnet | Windows-02-pip | Windows-02-nic | WindowsNSG | Windows-02-disk | 127 | windows | MicrosoftWindowsServer | WindowsServer | 2016-Datacenter | WindowsAVS


## Scenario Diagram
<img src="../../../images/vmconfig.png" width="80%" height="80%"> 


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



