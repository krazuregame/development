<#   
================================================================================ 
 Name: Remote_VM_Configuration.txt 
 Purpose: Pre-setting for Remote Session between hosts
 Author: molee
 Description:  
 Limitations/Prerequisite:
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
 ================================================================================ 
#>




#*******Remote Session Host********

#Azure Powershell Module 설치
Install-Module -Name AzureRM
Import-Module AzureRM

# 모니터링 서버에서 winrm 관련 설정이 모니터링 가능한지 확인
winrm s winrm/config/client '@{TrustedHosts="*"}'
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/client @{AllowUnencrypted=`"true`"}"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service/auth @{Basic=`"true`"}"

#모니터링 대상 서버들에 대한 NetBios 이름을 모두 C:\Windows\System32\Drivers\etc 폴더내 hosts 파일에 명시
#Private IP 조회 스크립트

Get-AzureRmNetworkInterface -ResourceGroupName $resourcegroup | ForEach { $Interface = $_.Name; $IPs = $_ | Get-AzureRmNetworkInterfaceIpConfig | Select PrivateIPAddress; Write-Host $Interface $IPs.PrivateIPAddress }


#방화벽 Disable
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

#Ping 허용
New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4


#*******Remote Session Target********

# Windows
#모니터링 대상서버 - 모니터링 대상 서버에 winrm 관련 기본 설정이 되었는지 확인
Start-Process "C:\windows\system32\winrm.cmd" "qc /q"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service @{AllowUnencrypted=`"true`"}"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service/auth @{Basic=`"true`"}"

#Microsoft Azure의 Windows Server는 UAC가 기본적으로 켜져있음.
#최초 생성된 Built-In 관리자 계정은 로컬 세션에서는 UAC 영향을 받지 않음. Built-In 관리자, 추후 생성된 관리자는 원격에서 접근시 모두 UAC에 영향을 받아, 기본 Users 권한을 가지게 됨. 
#이에 대해 Administrators 권한을 가지도록 모니터링 대상 서버에 레지스트리를 변경해야 함. (UAC에 대해서 잘 이해하지 못할 경우, UAC에 대해서 사전 숙지 필요)

Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord

# 방화벽 끄기
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Ping 허용
New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4

#VM 생성시 타임존 안바꿨으면 KST로 변경
Set-TimeZone -Name "korea Standard Time"


# Linux

# Firewall Off
sudo systemctl stop firewalld.service

#Add MS Package repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo yum install -y powershell

# Install PSRP
sudo yum -y install omi-psrp-server

# open PSRP http 5985
sudo sed -i "s/httpport=0/httpport=0,5985/g" /etc/opt/omi/conf/omiserver.conf
sudo /opt/omi/bin/service_control restart
