# Azure Monitor in Game Industry

## 1. Overview
게임 산업은 다른 Enterprise 서비스 구축보다 Real-Time 기반으로 돌아가기 때문에(Network Latency 및 service persistence에 민감함) Azure IaaS Service Built-Up 시 모니터링 기능을 구축하는 것이 중요하다. 

### 1.1 Constraints
도입이 시급함 사용시 VM Deploy, VM/Process Monitoring 등 주요 기능들에 대한 PowerShell Sample Script

### 1.2 Requirement
도입이 시급함 사용시 VM Deploy, VM/Process Monitoring 등 주요 기능들에 대한 PowerShell Sample Script

## 2. Environment Set-Up
### 2.1 Development Environment Set-Up
* [개발환경구축](./docs/environment.md)

### 2.2 Monitoring Environment Set-Up
* [모니터링환경구축](./docs/environment.md)

## 3. Azure Function PowerShell Guide
기능 | 가이드
------|--------------------------
SPN(Service Principal Name) Account |[Link](./docs/spn.md)
Deploy Infra/VM |[Link](./docs/deploy.md)
VM Post-Job |[Link](./docs/vmpostjob.md)
Monitoring Pre-Condition |[Link](./docs/monitorprecon.md)
Monitor VM/Process |[Link](./docs/monitor.md)
