# Azure AD SPN Account - PowerShell Example

* 생성 Code: [Link](https://github.com/krazuregame/development/blob/master/script/powershell/src/1_1_Create_SPN.ps1)
* 로그인 Code: [Link](https://github.com/krazuregame/development/blob/master/script/powershell/src/1_2_SPN_Login.ps1)

## 예제 설명
다음을 순차적으로 실행한다.

1. 본인의 Azure account 계정에  ID/PW 를 사용하여 로그인하다.
2. Azure AD Application을 생성한다. 
3. AD Application에 Service Principal을 생성한다.
4. AD Service Principal 에 Contributor Role을 생성한다. 

## SPN Scenario Diagram
<img src="../../../images/SPN.png" width="60%" height="60%">
