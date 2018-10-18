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


## 

## Configure & Start
