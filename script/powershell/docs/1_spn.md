# Azure AD SPN Account - PowerShell Example

* Code: https://github.com/krazuregame/development/blob/master/script/powershell/src/1_1_Create_SPN.ps1
* Code: https://github.com/krazuregame/development/blob/master/script/powershell/src/1_2_SPN_Login.ps1

## 예제 설명
다음을 순차적으로 실행한다.

1. 본인의 Azure account 계정에  ID/PW 를 사용하여 로그인하다.
2. Azure AD Application을 생성한다. 
3. AD Application에 Service Principal을 생성한다.
4. AD Service Principal 에 Contributor Role을 생성한다. 

## 예제 실행 방법 및 결과
예제 코드는 Azure Storage Acccount 이름과 Azure Storage Account Key를 환경변수로 설정해준다.

```bash
export AZURE_STORAGE_ACCOUNT="storageaccount"
export AZURE_STORAGE_KEY="*****"
```

예제 코드의 실행 결과는 다음과 같다
```bash
.venv/bin/python blob/example.py
```
