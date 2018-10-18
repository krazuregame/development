# Azure Deploy Infrastructure with CSV - PowerShell Example

* Code: https://github.com/krazuregame/development/script/powershell/src/2_1_Bulk_Infrastructure_Creation_CSV.ps1
* CSV 파일 예제 : https://github.com/krazuregame/development/script/powershell/src/Infraconfig.csv
         
## 예제 설명
CSV 파일의 정보를 읽어들여, 해당 값들에 맞추어 가상머신이 생설될 Infrastructure를 선구성한다.

생성할 Azure의 리소스들은 다음과 같다.

1. 리소스그룹(Resource Group)
2. 가상네트워크(Virtual Network)
3. 서브넷(Subnet)
4. 네트워크 보안 그룹(Network Security Group)

ResourceGroup | Location | Subnetname | SubnetAddress | vnetname | vnetAddress | nsgname | nsgrulename | port | priority
------------ | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- 
NetworkRG	| Korea Central	| LinuxSubnet	| 10.50.1.0/24	| DemoVnet	| 10.50.0.0/16	| LinuxSSH	| LinuxNSG	| 22	| 1010
NetworkRG	| Korea Central	| WindowsSubnet	| 10.50.2.0/24	| DemoVnet	| 10.50.0.0/16	| WindowsRDP	| WindowsNSG	| 3389	| 1030


## Powershell 

1. CSV 파일 Import하기 [문서링크](https://docs.microsoft.com/ko-kr/powershell/module/Microsoft.PowerShell.Utility/Import-Csv?view=powershell-6)
~~~
Import-csv 
~~~

2. Foreach를 활용한 looping 작업 [문서링크](https://docs.microsoft.com/ko-kr/powershell/module/Microsoft.PowerShell.Core/ForEach-Object?view=powershell-6)
~~~
$a = 1
$b = 2
$c = 3
$d = $a, $b, $c
Foreach($i in $d)
{
         $i + 5
}
**$d에 저장된 $a, $b, $c의 값이 순차적으로 looping 되어 6, 7, 8의 값이 순차적으로 출력된다** 
~~~


## Code 설명

1. 실습1에서 생성한 AD Service Principal을 통하여 Azure에 로그인한다.
~~~
$tenantID = "*************************"
$appid = "*************************"
$pwd = Get-Content 'C:\LoginCred.txt' | ConvertTo-SecureString
$cred = New-object System.Management.Automation.PSCredential("$appid", $pwd)
Add-AzureRmAccount -Credential $cred -TenantID $tenantId -ServicePrincipal
~~~

2. 

## SPN Scenario Diagram
<img src="../../../images/SPN.png" width="60%" height="60%">
