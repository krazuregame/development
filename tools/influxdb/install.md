## InfluxDB OSS installation Requirements

### InfluxDB OSS networking ports
디폴트로 InfluxDB는 다음의 network ports 를 사용함
* TCP port 8086 : client-server communication over InfluxDB’s HTTP API
* TCP port 8088 : the RPC service for backup and restore

### Network Time Protocol (NTP)
InfluxDB는 UTC 호스트 로컬 시간을 사용. NTP를 사용하여 호스트 간의 시간 동기화 필요

## Install
Time-Series DBMS Version 1.6.4

### Ubuntu: 
1. Add the InfluxData repository with the following commands:
    ```bash
    curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
    source /etc/lsb-release
    echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
    ```
2. Then, install and start the InfluxDB service:
    ```bash
    sudo apt-get update && sudo apt-get install influxdb
    sudo service influxdb start
    ```

### Windows
1. Download the influxdb windows distribution and Unzip.
    * https://dl.influxdata.com/influxdb/releases/influxdb-1.6.4_windows_amd64.zip
2. Create the directory `C:\Program Files\InfluxDB` 
3. Place the influx.exe, influxd.exe and the influxdb.conf config file into `C:\Program Files\InfluxDB`
4. Edit the configuration file to meet your needs
5. Switch to the InfluxDB directory and start the application:

    ```
    > C:\Users\User>cd "C:\Program Files\InfluxDB\"
    > C:\Program Files\InfluxDB>influxd.exe

## Configure
* data path : /var/lib/influxdb/data
* meta path : /var/lib/influxdb/meta
* wal path : /var/lib/influxdb/wal
* config path
    * linux os : /etc/influxdb/influxdb.conf
    * window os : C:\Program Files\Influxdb\influxdb.conf
* log path : /var/log/influxdb

## Test
### Start & Stop
start
``` bash
cosmos@tig-linux:~$ sudo service influxdb start
```

stop 
``` bash
cosmos@tig-linux:~$ sudo service influxdb stop
```

status
```
cosmos@tig-linux:/var/log/influxdb$ service influxdb status
● influxdb.service - InfluxDB is an open-source, distributed, time series databa
   Loaded: loaded (/lib/systemd/system/influxdb.service; enabled; vendor preset:
   Active: active (running) since Fri 2018-10-19 10:05:43 UTC; 3 days ago
     Docs: https://docs.influxdata.com/influxdb/
 Main PID: 29558 (influxd)
    Tasks: 12 (limit: 4915)
   CGroup: /system.slice/influxdb.service
           └─29558 /usr/bin/influxd -config /etc/influxdb/influxdb.conf
```

### Create Database
influxdb 를 설치하면 아래와 같은 명령어로 influxdb 접속 가능

```
cosmos@tig-linux:~$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.6.4
InfluxDB shell version: 1.6.4
```

접속하여 해당 database 생성
```
> create database TIG
> show databases
name: databases
name
----
_internal
TIG
``` 

생성한 database 에 key, value insert
```
> use TIG
Using database TIG
> INSERT cpu,host=serverA,region=us_west value=0.64
> select * from cpu
name: cpu
time                           host    region  value
----                           ----    ------  -----
2018-10-23T03:21:27.571110443Z serverA us_west 0.64
```

DB 접속 가능한 User/ Permission 생성

```
> CREATE USER jeff WITH PASSWORD '1234' WITH ALL PRIVILEGES
```

### Test

telegraf 에서 influxdb 로 모니터링 데이타가 정상 수집되고 있는지 확인

```
cosmos@tig-linux:~$ influx -host ${influxdb_ip} -username ${influxdb_name} -password ${influxdb_password}
Visit https://enterprise.influxdata.com to register for updates, InfluxDB server management, and monitoring.
Connected to http://${influxdb_ip}:8086 version 1.0.0
InfluxDB shell version: 1.1.1

> use TIG
Using database TIG
> show MEASUREMENTS
name: measurements
name
----
cpu
disk
diskio
docker
docker_container_blkio
docker_container_cpu
docker_container_mem
docker_container_net
docker_container_status
kernel
mem
net
net_response
processes
swap
system
win_cpu
win_disk
win_diskio
win_mem
win_net
win_swap
win_system

> select * from cpu limit 10;
name: cpu
time                    cpu             host            usage_guest     usage_guest_nice        usage_idle              usage_iowait            usage_irq      usage_nice       usage_softirq           usage_steal     usage_system           usage_user
----                    ---             ----            -----------     ----------------        ----------              ------------            ---------      ----------       -------------           -----------     ------------           ----------
1539667730000000000     cpu-total       388efd891a32    0               0      093.55828220858874       0               0               0.10224948875255375    01.5337423312883607      4.805725971370117
1539667740000000000     cpu-total       388efd891a32    0               0      2.024291497975714        86.43724696356321       0               0              0.2024291497975723       0               2.530364372469651       8.805668016194433
1539667750000000000     cpu-total       388efd891a32    0               0      90.7999999999995 3.7999999999999328      0               0               0      01.1999999999999675      4.199999999999993
1539667760000000000     cpu-total       388efd891a32    0               0      98.09809809809855        0.6006006006006263      0               0              00               0.40040040040042935     0.9009009009009393
1539667770000000000     cpu-total       388efd891a32    0               0      97.68844221105537        1.3065326633165386      0               0              0.1005025125628165       0               0.2010050251256241      0.7035175879396307
1539667780000000000     cpu-total       388efd891a32    0               0      97.39217652958851        1.3039117352055676      0               0              00               0.40120361083248784     0.9027081243731511
1539667790000000000     cpu-total       388efd891a32    0               0      98.39518555667033        0.5015045135407373      0               0              00               0.3009027081243854      0.8024072216649802
1539667800000000000     cpu-total       388efd891a32    0               0      97.19999999999943        1.5000000000000484      0               0              00               0.2999999999999741      0.9999999999999375
1539667810000000000     cpu-total       388efd891a32    0               0      96.59659659659657        1.9019019019018775      0               0              0.10010010010009787      0               0.3003003003003114      1.1011011011010945
1539667820000000000     cpu-total       388efd891a32    0               0      98.39679358717466        0.5010020040078471      0               0              00               0.3006012024048222      0.801603206412954
```
