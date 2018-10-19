# Excute Post Script to Azure VMs

* Powershell Code: [Link](https://github.com/krazuregame/development/blob/master/script/powershell/src/3_2_Excute_Post_Script.ps1)
* Post Script 예제 : [Linux용 Script](https://github.com/krazuregame/development/blob/master/script/powershell/src/InitialScriptLinux.sh), [Windows용 Script](https://github.com/krazuregame/development/blob/master/script/powershell/src/InitialScriptWindows.ps1)

## Microsoft 참고 문서
* Azure Extension 참고 문서:  [Linux Extension Link](https://docs.microsoft.com/ko-kr/azure/virtual-machines/extensions/custom-script-linux), [Windows Extension Link](https://docs.microsoft.com/ko-kr/azure/virtual-machines/extensions/custom-script-windows)


Type | Windows | Linux
------------ | ------------- | -------------
publisher | Microsoft.Compute | Microsoft.Compute.Extensions
형식 | CustomScriptExtension | CustomScript
typeHandlerVersion | 1.9 | 2.0

* Azure SAS(Shared Access Signature) 참고 문서 : [Docs Link](https://docs.microsoft.com/ko-kr/azure/storage/common/storage-dotnet-shared-access-signature-part-1)


## 예제 설명
Windows와 Linux에 실행될 스크립트를 작성한 뒤, Azure Blob Storage에 업로드하여 각 가상머신에 운영체제에 맞게 스크립트를 실행한다.


Custom Script Extension은 가상머신에서 스크립트를 다운로드하고 실행한다. 
이 Extension은 가상머신 배포 후, 소프트웨어 설치 또는 기타 구성/관리 작업에 유용하며, 스크립트를 Azure Storage 또는 기타 액세스가 가능한 인터넷 위치에서 다운로드하여 실행할 수 있다.


1. 운영체제 / 버전에 따라 적용할 스크립트 작성
2. Azure Blob에 스크립트 파일 업로드
3. SAS(Shared Access Signature)키 생성
4. SAS키를 통한 Blob 스크립트 파일 접근
5. Azure Custom Script Extension을 통해 각 가상머신에 스크립트 적용







## Scenario Diagram
<img src="../../../images/postscript.png" width="80%" height="80%"> 


## Azure Blob Storage에 스크립트 파일 업로드 / SAS 키 생성
1. Azure 포탈에서 저장소 계정으로 이동하여, "저장소계정 - Blob 저장소 - 컨테이너"에 스크립트 파일을 업로드 한다. (없으면 생성) 


<img src="../../../images/BlobUpload.png" width="80%" height="80%"> 


2. 저장소 계정에서 "엑세스 키" 메뉴를 선택하여, SAS Key를 생성하고 복사한다.

<img src="../../../images/SASkey.png" width="80%" height="80%"> 

> "저장소 계정" / "엑세스 키" / "스크립트 파일 URL" 를 기록하여 둔다. 이 후, Powershell 스크립트에 적용한다.
>> "$storageAccountName / $storageAccountKey / $scripturi" 변수에 각각 적용




## Powershell 코드

* 공통 정보 작성 (저장소 계정 / SAS 키)

```powershell
$storageAccountName = "moonsunscripts"
$storageAccountKey = "**********************************"
$ProtectedSettings = @{"storageAccountName" = $storageAccountName; "storageAccountKey" = $storageAccountKey}
```

* Linux Custom Extension

```powershell
$linuxuri = "https://**********.blob.core.windows.net/scripts/InitialScriptLinux.sh"
$linuxSettings = @{"fileUris" = @($linuxuri); "commandToExecute" = "./InitialScriptLinux.sh"}
        
Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name $Post-Script-Linux `
-Publisher "Microsoft.Azure.Extensions" -Type "customScript" -TypeHandlerVersion 2.0 -Settings $linuxSettings -ProtectedSettings $ProtectedSettings
```

* Windows Custom Extension

```powershell
$winuri = "https://**********.blob.core.windows.net/scripts/InitialScriptWindows.ps1"
$winSettings = @{"fileUris" = @($winuri); "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File InitialScriptWindows.ps1"}
        
Set-AzureRmVMExtension -ResourceGroupName $resourceGroup -Location $location -VMName $vmName -Name Post-Script-Windows `
-Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion 1.9 -Settings $winSettings -ProtectedSettings $ProtectedSettings
```


* Custom Extension 조회 / 삭제

```powershell
# Get Status of Custom Extension
Get-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $scriptName

# REMOVE VM EXTENSION
Remove-AzureRmVMExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $scriptName
```
