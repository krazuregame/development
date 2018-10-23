## Grafana installation Requirements

### Grafana ports
디폴트로 Grafana 다음의 network ports 를 사용함
* HTTP port 3000

## Install
Version 5.3.1 October 16, 2018

### Ubuntu: 
1. Add the following line to your /etc/apt/sources.list file.
    ```bash
    deb https://packagecloud.io/grafana/stable/debian/ stretch main
    ```
2. Then add the Package Cloud key. This allows you to install signed packages.
    ```bash
    curl https://packagecloud.io/gpg.key | sudo apt-key add -
    ```
3. Update your Apt repositories and install Grafana
    ```
    sudo apt-get update
    sudo apt-get install grafana
    ```

### Windows
1. Download the grafana windows distribution and Unzip.
    * https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.3.1.windows-amd64.zip 
2. Edit the configuration file to meet your needs
3. Start Grafana by executing grafana-server.exe, located in the bin directory

## Configure
* Installs binary : /usr/sbin/grafana-server
* Installs Init.d script : /etc/init.d/grafana-server
* Creates default file (environment vars) : /etc/default/grafana-server
* Installs configuration file : /etc/grafana/grafana.ini
* Installs systemd service (if systemd is available) name : grafana-server.service
* The default configuration sets the log file :  /var/log/grafana/grafana.log
* The default configuration specifies an sqlite3 db :  /var/lib/grafana/grafana.db
* Installs HTML/JS/CSS and other Grafana files :  /usr/share/grafana
### Security
어드민 계정과 암호는 반드시 로그인 후 변경해야 하고 유저들을 추가하여 해당 항목에 Viewer 권한을 주어 접속할수 있도록 변경
### HTTPS/SSL Setting
모니터링 구축 서버는 민감한 정보들을 가지고 있기 때문에 HTTPS/SSL 정보가 설정되어야 함

```
#################################### Server #################################### 
[server] 
# Protocol (http or https) 
protocol = https 

# The ip address to bind to, empty will bind to all interfaces 
http_addr = 0.0.0.0 

# The http port to use 
http_port = 3000 

# The public facing domain name used to access grafana from a browser 
;domain = localhost 

# Redirect to correct domain if host header does not match domain 
# Prevents DNS rebinding attacks 
;enforce_domain = false 

# The full public facing url 
;root_url = %(protocol)s://%(domain)s:%(http_port)s/ 

# Log web requests 
;router_logging = false 

# the path relative working path 
;static_root_path = public 

# enable gzip 
;enable_gzip = false 

# https certs & key file 
cert_file = /usr/local/ssl/crt/certificate.cer 
cert_key = /usr/local/ssl/private/private_key.key 
```

## Test
### Start & Stop
start
``` bash
cosmos@tig-linux:~$ sudo service grafana-server start
```

stop 
``` bash
cosmos@tig-linux:~$ sudo service grafana-server stop
```

status
```
cosmos@tig-linux:~$ sudo service grafana-server status
● grafana-server.service - Grafana instance
   Loaded: loaded (/usr/lib/systemd/system/grafana-server.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2018-10-23 20:57:27 UTC; 3s ago
     Docs: http://docs.grafana.org
 Main PID: 8231 (grafana-server)
    Tasks: 8 (limit: 4915)
   CGroup: /system.slice/grafana-server.service
           └─8231 /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --pidfile=/var/run/grafana/grafana-server.pid cfg:default.paths.logs=/var/log/grafana cfg:d
```

Test

To run Grafana open your browser and go to the port you configured above, e.g. http://localhost:3000/.
default login user/password : admin/admin

