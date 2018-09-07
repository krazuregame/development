# Azure Blob - Python Example

* Code: https://github.com/krazuregame/development/tree/master/script/sdk/python-sample/blob/example.py

## 예제 설명
다음을 순차적으로 실행한다.

1. Container 생성
2. Container 권한 생성
3. Upload 파일 생성
4. 생성한 파일을 Container에 Blob으로 Upload
5. Blob 목록 조회
6. Blob Download
7. Container 삭제

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
