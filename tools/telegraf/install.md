## Telegraf to InfluxDB
### Architecture

* logical diagram
<img src="../../images/TelegrafInfluxArchitecture.png" width="70%" height="70%">

* TIG monitoring with Telegraf Agent
    - 각 DB서버에 모니터링 데이터 수집 agent로서 telegraf를 백그라운드로 프로세스로 실행하여 모니터링 서버로 push하는 방식

    - 이런 구성에서는 매번 서버가 추가 될 때마다 해당 서버에 agent를 설치해줘야 하는 번거로움이 있음

    - 모니터링 서버를 통해서 다른서버를 접근할 수 없어 보안상 안전
    - 모니터링 서버에 수집 부하가 집중되는 문제를 피할 수 있음

        ![](../../images/TIG1.png)
 
*  TIG monitoring without Telegraf Agent
    - 모니터링 서버에서 각 서버로 접속하여 get/polling 하는 방식으로 구성.
    - 모니터링 대상 서버가 추가될 때마다 agent용 프로그램들을 설치할 필요 없이 간단히 설정만 추가
    -  모니터링 서버가 보안 위험에 노출될 경우 다른 서버들로 접속이 가능한 위험 존재

        ![](../../images/TIG2.png)

## Install
Time-Series Data Collector Version 1.8.2

### Ubuntu: 
1. Add the InfluxData repository with the following commands:
    ```bash
    curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
    source /etc/lsb-release
    echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
    ```
2. Then, install and start the Telegraf service:
    ```bash
    sudo apt-get update && sudo apt-get install telegraf
    sudo service telegraf start
    ```

### Windows

1. Download the telegraf windows distribution and Unzip.(https://dl.influxdata.com/telegraf/releases/telegraf-1.8.2_windows_amd64.zip)
2. Create the directory `C:\Program Files\Telegraf` (if you install in a different
   location simply specify the `--config` parameter with the desired location)
3. Place the telegraf.exe and the telegraf.conf config file into `C:\Program Files\Telegraf`
4. To install the service into the Windows Service Manager, run the following in PowerShell as an administrator (If necessary, you can wrap any spaces in the file paths in double quotes ""):

   ```
   > C:\"Program Files"\Telegraf\telegraf.exe --service install
   ```

5. Edit the configuration file to meet your needs
6. To check that it works, run:

   ```
   > C:\"Program Files"\Telegraf\telegraf.exe --config C:\"Program Files"\Telegraf\telegraf.conf --test
   ```

7. To start collecting data, run:

   ```
   > net start telegraf
   ```

## Configure
linux os config path : /etc/telegraf/telegraf.conf

window os config path : C:\"Program Files"\Telegraf\telegraf.conf

### Common Output Config 
여기서는 telegraf 에서 정보를 보내는 부분으로 Output단을 Influx DB로 설정함 

``` bash
###############################################################################
#                                  OUTPUTS                                    #
###############################################################################
[[outputs.influxdb]]
  urls = ["http://influxdb:8086"]
  database = "databasename"
  retention_policy = ""
  write_consistency = "any"
  timeout = "5s"
  username = "username"
  password = "password"
```

### System Config
Monitoring 하고자 하는 Section 부분의 주석을 해제함
``` bash
###############################################################################
#                                  PLUGINS                                    #
###############################################################################

[[inputs.cpu]]
  percpu = false
  totalcpu = true
  fielddrop = ["time_*"]

[[inputs.diskio]]
  skip_serial_number = true

[[inputs.disk]]
# interval = "%INTERVAL_DISK%"

[[inputs.mem]]

# Get the number of processes and group them by status
[[inputs.processes]]

# Read metrics about swap memory usage
[[inputs.swap]]

# Get kernel statistics from /proc/stat
[[inputs.kernel]]

[[inputs.system]]
  [inputs.system.tags]
    n_cpus = "%N_CPUS%"

[[inputs.net]]
  interfaces = ["eth0"]
  [inputs.net.tagdrop]
  interface = ["all"]

[[inputs.net_response]]
  protocol = "tcp"
  address = ":80"
```

### Redis Config
``` bash

# Read metrics from one or many redis servers
[[inputs.redis]]
  ## specify servers via a url matching:
  ##  [protocol://][:password]@address[:port]
  ##  e.g.
  ##    tcp://localhost:6379
  ##    tcp://:password@192.168.99.100
  ##    unix:///var/run/redis.sock
  ##
  ## If no servers are specified, then localhost is used as the host.
  ## If no port is specified, 6379 is used
  servers = ["tcp://localhost:6379"]

  ## specify server password
  password = "s#cr@t%"
```

## Test
### Start & Stop
start
``` bash
#Linux
cosmos@tig-linux:~$ sudo service telegraf start

#Window 
> net start telegraf
```

stop 
``` bash
#Linux
cosmos@tig-linux:~$ sudo service telegraf stop

#Window 
> net stop telegraf
```

status
```
cosmos@tig-linux:~$ sudo service telegraf status
● telegraf.service - The plugin-driven server agent for reporting metrics into I
   Loaded: loaded (/lib/systemd/system/telegraf.service; enabled; vendor preset:
   Active: active (running) since Thu 2018-10-18 22:32:02 UTC; 3min 26s ago
     Docs: https://github.com/influxdata/telegraf
 Main PID: 7874 (telegraf)
    Tasks: 11 (limit: 4915)
   CGroup: /system.slice/telegraf.service
           └─7874 /usr/bin/telegraf -config /etc/telegraf/telegraf.conf -config-

Oct 18 22:32:02 tig-linux systemd[1]: Started The plugin-driven server agent for
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Starting Teleg
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Loaded inputs:
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Loaded aggrega
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Loaded process
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Loaded outputs
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Tags enabled:
Oct 18 22:32:02 tig-linux telegraf[7874]: 2018-10-18T22:32:02Z I! Agent Config:
lines 1-17/17 (END)

```

Test
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
