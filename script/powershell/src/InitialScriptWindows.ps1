#모니터링 대상 서버에 winrm 관련 기본 설정이 되었는지 확인
Start-Process "C:\windows\system32\winrm.cmd" "qc /q"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service @{AllowUnencrypted=`"true`"}"
Start-Process "C:\windows\system32\winrm.cmd" "set winrm/config/service/auth @{Basic=`"true`"}"

#윈도우 업데이트 끄기(=레지스트리 변경 작업아래와 동일하게)
Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1

#방화벽 끄기
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

<#데이터 디스크 추가
Get-Disk | Where partitionstyle -eq 'raw' | `
Initialize-Disk -PartitionStyle MBR -PassThru | `
New-Partition -AssignDriveLetter -UseMaximumSize | `
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data_Disk1" -Confirm:$false
#>

#VM 타임존 KST로 변경
Set-TimeZone -Name "korea Standard Time"

