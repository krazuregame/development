# Azure Deploy/Monitor Sample Code

## 1. Overview
IaaS 기반의 Azure 기능들 사용시 Infra/VM 을 배포하고 배포된 VM을 모니터링하는 PowerShell Sample Code.
Azure 명령 수행시에 다양한 개발 방법들이 제공되나(SDK, API, CLI) 여기서는 가장 Basic 한 Azure PowerShell을 사용하여 해당 기능 구현  

### 1.1 Sample Source Main Sequence Diagram
Deploy/Monitor 소스의 Sequence Diagram 은 다음과 같다
1. SPN(Service Principal Name) Account을 생성하고 로그인한다.
2. 해당 계정에 Infra/VM을 배포한다.
3. 배포된 VM 정보를 Discovery하여 csv파일에 저장하고 각각의 VM 들에 구동시 필요한 scripts 들을 실행한다.
4. 모니터링을 하기 위해 모니터링 VM 에 사전 작업들을 설정한다. 
5. 구축된 VM 정보 및 특정 Process 들을 모니터링한다. 

<img src="../../images/MainSequenceDiagram.png" width="80%" height="80%">

## 2. Azure PowerShell 개발 환경 구축
Azure PowerShell은 Azure Resurce 관리를 위해 Azure Resource Manager Model을 사용하는 cmdlet 집합

### PowerShell
PowerShell은 마이크로소프트가 개발한 확장 가능한 명령 줄 인터페이스(CLI) 셸 및 스크립트 언어를 특징으로 하는 명령어 인터프리터.
스크립트 언어는 닷넷 프레임워크 2.0을 기반으로 객체 지향에 근거해 설계.
(https://docs.microsoft.com/en-us/powershell/azure/overview?view=azurermps-6.9.0)
### Install Windows PowerShell
Supported OS: Windows 10, Windows 8.1, 8.0, Windows 7 SP1, Windows Server 2008 R2 버전부터 PowerShell 기본 내장(ISE 버전 설치는 OS에 따라 다름)
### Install Azure Powershell Module
설치 가이드 문서 : [Link](https://docs.microsoft.com/ko-kr/powershell/azure/install-azurerm-ps?view=azurermps-6.10.0)

```powershell
Install-Module -Name AzureRM -AllowClobber
Import-Module AzureRM
```

### PowerShell Version
```bash
PS C:\Users\inpa> $PSVersionTable
Name                           Value                                                                                                                                                                                                                                           
----                           ----- 
PSVersion                      5.1.18237.1000
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.18237.1000                        
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
```

## 3. PowerShell Guide
기능 | 가이드
------|--------------------------
SPN(Service Principal Name) Account |[Link](./docs/1_spn.md)
Deploy Infra |[Link](./docs/2_deploy_infra.md)
Deploy VM |[Link](./docs/3_deploy_vm.md)
VM Post-Job |[Link](./docs/4_vm_post_jobs.md)
Monitoring Pre-Condition |[Link](./docs/99_set_monitoring_server.md)
Monitor VM/Process |[Link](./docs/5_monitor_vm_process.md)
