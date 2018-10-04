어플리케이션 구성시 모니터링을 위해 구축되는 3Step
- 어플리케이션 구성 요소(웹 서버, 데이터베이스, 로드 밸런서)

1. Collector: 어플리케이션에서 유의미한 데이타들을 모니터링 데몬을 통해 수집
2. Database: Elasticsearch나 InfluxDB와 같은 데이타 데이터베이스 저장
3. Dashboard: Grafana나 Kibana 와 같은 도구로 시각화


## 3. Grafana ##
시스템 모니터링 대시보드를 이쁘게 보여주는 툴로 시계열 데이터 베이스를 연동하여 시각화함
* 원하는 메트릭 지표 수집만 하면 Grafana를 통해 쉽게 시각화 가능
* 설치가 매우 용이함
* 연결 가능 Database
    - CloudWatch, Elasticserarch, Graphite, InfluxDB, OpenTSDM, Prometheus ...
* Notification
    - Email, HipChat, Pushover, webhook, Line, Slack, Telegram
* Alerting
* Dashbloard
    - https://grafana.com/dashboards
* Plugins
    - https://grafana.com/plugins

### 3.1 Install & Setup Guide 
* [Grafana 환경구축](./grafana/install.md)
* [Grafana 대쉬보드구축](../grafana/dashboard.md)
