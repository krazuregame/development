# Powershell Remote 가상머신 구성

## Microsoft 참고 문서
* Powershell 원격실행 참고 문서 :  [Remote Command Link](https://docs.microsoft.com/ko-kr/powershell/scripting/core-powershell/running-remote-commands?view=powershell-6)
* WinRM 보안 참고 문서 : [Remote Security Link](https://docs.microsoft.com/ko-kr/powershell/scripting/setup/winrmsecurity?view=powershell-6)


## 예제 설명
Azure에서 운영중인 Linux와 Windows 가상머신에 원격실행을 할 수 있도록 가상머신을 구성한다.  

MonitoringVM에 RDP로 접속하여 Powershell을 실행한다.


1. Powershell AzureRM 모듈 설치
```powershell
#Azure Powershell Module 설치
Install-Module -Name AzureRM
Import-Module AzureRM
```
2. 원격실행이 가능하도록 WinRM 설정
```powershell
# 모니터링 서버에서 winrm 관련 설정이 모니터링 가능한지 확인
winrm s winrm/config/client '@{TrustedHosts="*"}'
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/client @{AllowUnencrypted=`"true`"}"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service/auth @{Basic=`"true`"}"
```
> Azure에서 운영중인 가상머신과 해당 Private IP를 조회
```powershell
Get-AzureRmNetworkInterface -ResourceGroupName $resourcegroup | ForEach { $Interface = $_.Name; $IPs = $_ | Get-AzureRmNetworkInterfaceIpConfig | Select PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress }
```
3. Target 머신들의 정보를 C:\Windows\System32\Drivers\etc 폴더내 hosts 파일에 명시
```powershell
      10.50.x.x     Linux-01          
      10.50.x.x     Windows-01              
```
4. 기타 설정
```powershell
# 방화벽 Off
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# ICMP ping 허용
New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
```


