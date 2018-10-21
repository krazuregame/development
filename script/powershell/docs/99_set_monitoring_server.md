# Powershell Remote 가상머신 구성

## Microsoft 참고 문서
* Powershell 원격실행 참고 문서 :  [Remote Command Link](https://docs.microsoft.com/ko-kr/powershell/scripting/core-powershell/running-remote-commands?view=powershell-6)
* WinRM 보안 참고 문서 : [Remote Security Link](https://docs.microsoft.com/ko-kr/powershell/scripting/setup/winrmsecurity?view=powershell-6)


## 예제 설명
Azure에서 운영중인 Linux와 Windows 가상머신에 원격실행을 할 수 있도록 가상머신을 구성한다.  

MonitoringVM에 RDP로 접속하여 Powershell을 실행한다.


1. Powershell AzureRM 모듈 설치
```powershell
Install-Module -Name AzureRM
Import-Module AzureRM
```
2. 원격실행이 가능하도록 WinRM 설정
```powershell
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



## 원격 실행 예제
해당 가상머신에서 다른 가상머신으로 원격실행을 하여 결과값을 받기 위해서는, 대상 가상머신들의 OS Credential 정보를 알고 있어야 한다.

```powershell
$username = 'azureadmin'
$userpw = '*********'
$secureuserpw = $userpw | ConvertTo-SecureString -AsPlainText -Force

$oscred = New-Object pscredential ($username, $secureuserpw)

혹은 json 파일로 해당 정보를 저장하여, 스크립트에서 불러와 사용한다.
```

Invoke-Command 명령어를 통하여, 원하는 명령어를 실행하여 결과값을 Return 받을 수 있다.

Host파일에 저장된 가상머신 이름을 사용하여 Bulk로 실행할 수 있다.



1. 대상이 Windows인 경우
```powershell 
Invoke-Command –ComputerName $ServerName -Credential $oscred -ScriptBlock { Get-Process }
```

2. 대상이 Linux인 경우
```powershell
$opt = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck
Invoke-Command -ComputerName $ServerName -Authentication Basic -SessionOption $opt -Credential $oscred -ScriptBlock { Get-Process }
```


* Background Job을 통한 기본 스크립트 예시

```powershell
$username = 'azureadmin'
$userpw = '********'
$secureuserpw = $userpw | ConvertTo-SecureString -AsPlainText -Force
$oscred = New-Object pscredential ($username, $secureuserpw)

$Serverlist = Get-Content -Path C:\Users\azureadmin\Desktop\Servername.txt
Foreach ($Servername in $Serverlist) {
    Start-Job -Name $ServerName -ScriptBlock { param($ServerName, $oscred)

if($servername -imatch "win")
{
    Invoke-Command –ComputerName $ServerName -Credential $oscred -ScriptBlock { Get-Process }
}

if($servername -imatch "lin")
{
    $o = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck
    Invoke-Command -ComputerName $ServerName -Authentication Basic -SessionOption $o -Credential $oscred -ScriptBlock { Get-Process }
}


    } -ArgumentList $Servername, $oscred

}

#Servername.txt
Linux-01
Linux-02
...
Windows-01
Windows-02
...

```

