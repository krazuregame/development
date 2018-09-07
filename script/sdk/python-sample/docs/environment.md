# 개발환경
## Azure 
필요사항
* Azure Subscription 
* Storage Account

## PC환경
필요사항
* Python
* Azure SDK for Python
* Azure CLI 2.0 - [Install Azure CLI] (https://docs.microsoft.com/ko-kr/cli/azure/install-azure-cli?view=azure-cli-latest)

###
예제 clone, Azure SDK 설치 및 virtualenv 생성

```bash
git clone https://github.com/krazuregame/development.git
cd development/script/sdk/python-sample/
sudo apt-get install python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -U pip
pip3 install azure
```

