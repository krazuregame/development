<#   
================================================================================ 
 Name: Basic_Remote_Session_Scriptblock.ps1
 Purpose: Test Basic Remote Session between hosts
 Author: molee
 Description:  
 Limitations/Prerequisite:
    * Credentials of Hosts
    * Must Run PowerShell (or ISE)  
    * Requires PowerShell Azure Module
 ================================================================================ 
#>


# Define
$ServerListPath = '~\Servername.txt'

# Ignore all error due to excute PowerSehll command
$ErrorActionPreference = "SilentlyContinue"

$ServerList = Get-Content -Path $ServerListPath

Foreach ($ServerName in $ServerList) {

    # Terminal이 종료되어도 실행을 보장하기 위하여 Background로 실행합니다.
    Start-Job -Name $ServerName -ScriptBlock { 
        param([string]$ServerName)

        # need to export environment config (JSON)           
        $AlertSendTime = $null
        $IsAlertSend   = $false

        # Background 실행 ScriptBlock 안에 function을 선언합니다..
        function SendSlack {
            Param(
                [string]$channel
                ,[string]$pretext
                ,[string]$title
                ,[string]$color
                ,[string]$message
            )            
    
            # Send Slack
            $payload = @{
                #"channel" = "#general"
                "channel" = $channel
                "icon_emoji" = ":bomb:"
                "title" = $title
                "color" = $color
                "text" = $message
                "username" = "Performance Checker BOT"
            }
            $webhook = "https://hooks.slack.com/services/**********************************"            
            Invoke-WebRequest -Body (ConvertTo-Json -Compress -InputObject $payload) -Method Post -UseBasicParsing -Uri $webhook | Out-Null
        }      

        If($ServerName.ToLower() -imatch "win") {
            
            # Windows 모니터링
            $AlertTime = $null
            While($true) {

                # Configuration을 Load합니다. Runtime 수정이 가능하기 위하여 매번 load합니다.
                $Env = Get-Content -Raw -Path '~\configuration.json' | ConvertFrom-Json
                $UserName = $Env.oscred.username
                $UserPW = $Env.oscred.userpw
                
                $SecureUserPw = $UserPw | ConvertTo-SecureString -AsPlainText -Force
                $OsCred = New-Object pscredential ($UserName, $SecureUserPw)

                $ServerStatus = $null
                    
                # Session 재사용을 위하여 Session.State가 Opened이고 Session.Avilability가 Available 인 Session을 가져오고 없으면 새로 생성하여 사용합니다.
                $Session = Get-PSSession -ComputerName $ServerName | ? {$_.State -eq "Opened" -and $_.Availability -eq "Available"}
                if ($Session -eq $null) {
                    $Session = New-PSSession -ComputerName $ServerName 
                }                
                
                $ServerStatus = Invoke-Command -Session $Session -Credential $oscred -ScriptBlock { ## {{{
                #$ServerStatus = Invoke-Command  -ComputerName 127.0.0.1 -ScriptBlock { ## {{{
                    # 원격 실행
                    # GameServer의 Process Count를 체크합니다.
                    $GameProcName = $Env.ServiceName
                    $GameProcCount = (Get-Process | ? {$_.Name -eq $GameProcName}).count                    

                    # 모니터링 하기 위한 Network Adapter의 description을 설정합니다.
                    #
                    # 단일 NIC를 사용할때는 아래를 사용하며
                    # 2개 이상의 NIC를 사용할 경우에는 interface index 가 2개 이상이 되므로 분리해서 추출해야합니다.
                    $ifindex=(Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -like "Ethernet*"}).InterfaceIndex
                    $ifdesc=(Get-NetAdapter -InterfaceIndex $ifindex).InterfaceDescription.replace('#','_')

                    $Counters = @(
                        "\Process($GameProcName)\Private Bytes",
                        '\processor(_total)\% processor time',
                        '\System\Processor Queue Length',
                        '\Memory\Pages/sec',
                        '\Paging File(_total)\% Usage',
                        '\Memory\Available MBytes',
                        "\Network Adapter($ifdesc)\Packets/sec",
                        "\Network Adapter($ifdesc)\Bytes Total/sec",
                        "\Network Adapter($ifdesc)\Bytes Sent/sec",
                        "\Network Adapter($ifdesc)\Bytes Received/sec"
                    )                 

                    # 부하를 줄이기 위하여 한번에 Query합니다.
                    $status = Get-Counter -Counter $Counters -ErrorAction SilentlyContinue

                    New-Object -TypeName PSCustomObject -Property @{
                        GameProcName   =$GameProcName
                        GameProcCount  =$GameProcCount
                        GameProcUsedMem=[decimal]("{0:n2}" -f ($status.CounterSamples.Where({$_.InstanceName -eq $GameProcName -AND $_.Path -match "Private Bytes"}).CookedValue / 1MB));
                        ProcessorTime  =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "processor time"}).CookedValue); 
                        ProcessorQueueLength   =[int]($status.CounterSamples.Where({$_.Path -match "Processor Queue Length"}).CookedValue);
                        PagesSec       =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Pages/sec"}).CookedValue);
                        PagingUsage    =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Paging File(_total)\% Usage"}).CookedValue);
                        AvailableMemory=[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Available MBytes"}).CookedValue);                        
                        PacketsSec     =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.InstanceName -eq $ifdesc -AND $_.Path -match "Packets/sec"}).CookedValue);
                        BytesTotalSec  =[decimal]("{0:n2}" -f ($status.CounterSamples.Where({$_.InstanceName -eq $ifdesc -AND $_.Path -match "Bytes Total/sec"}).CookedValue / 1MB));
                        BytesSentSec   =[decimal]("{0:n2}" -f ($status.CounterSamples.Where({$_.InstanceName -eq $ifdesc -AND $_.Path -match "Bytes Sent/sec"}).CookedValue / 1MB));
                        BytesRecvSec   =[decimal]("{0:n2}" -f ($status.CounterSamples.Where({$_.InstanceName -eq $ifdesc -AND $_.Path -match "Bytes Received/sec"}).CookedValue / 1MB));
                    }
                } # }}} ScriptBlock                 
                

                if ($Env.SqlDB.Stored -eq $true) {
                    # Sleep 시간단위로 Database에 누적 저장합니다.
                    # SQL Server DB의 Schema에 따라 insert query를 수정해야합니다.
                    $insertquery = "INSERT INTO TBL_ServerStatus `
                        ([PartitionKey], `
                        [Processor_Time], `
                        [Processor_Queue], `
                        [Pages_Sec], `
                        [GameServer_Memory], `
                        [GameServer_Running], `
                        [Paging_Usage_Percent], `
                        [packets_sec], `
                        [Available_Memory], `
                        [BytesTotal_sec], `
                        [BytesSentSec], `
                        [BytesRecvSec]) VALUES `
                        ('{0}',{1},{2},{3},{4},'{5}',{6},{7},{8},{9},{10},{11})" -f `
                        $ServerName, `
                        $ServerStatus.ProcessorTime, `
                        $ServerStatus.ProcessorQueueLength, `
                        $ServerStatus.PagesSec, `
                        $ServerStatus.GameProcUsedMem, `
                        $ServerStatus.GameProcCount, `
                        $ServerStatus.PagingUsage, `
                        $ServerStatus.PacketsSec, `
                        $ServerStatus.AvailableMemory, `
                        $ServerStatus.BytesTotalSec, `
                        $ServerStatus.BytesSentSec, `
                        $ServerStatus.BytesRecvSec

                        $conn = New-Object System.Data.SqlClient.SqlConnection
                        $conn.ConnectionString = $Env.SqlDB.ConnectionString
                        $conn.open()
                        $cmd = New-Object System.Data.SqlClient.SqlCommand
                        $cmd.connection = $conn
                        $cmd.commandtext = $insertquery
                        $execute = $cmd.executenonquery()
                        $conn.close()
                }

                if ($Env.InfluxDB.Stored -eq $true) {
                    #InfluxDB
                    $authheader = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes("$($Env.InfluxDB.User):$($Env.InfluxDB.Passwd)")))
                    $InfluxdbURI = "http://$($Env.InfluxDB.IP)/write?db=AzurePerf"                    
                    
                    $postParams = "server_status,host={0} ProcessorTime={1},ProcessorQueueLength={2},PagesSec={3},GameServerMemory={4},GameServerRunning={5},PagingUsage={6}`,PacketsSec={7},AvailableMemory={8},BytesTotalSec={9},BytesSentSec={10},BytesRecvSec={11}" -f `
                        $ServerName, `
                        $ServerStatus.ProcessorTime, `
                        $ServerStatus.ProcessorQueueLength, `
                        $ServerStatus.PagesSec, `
                        $ServerStatus.GameProcUsedMem, `
                        $ServerStatus.GameProcCount, `
                        $ServerStatus.PagingUsage, `
                        $ServerStatus.PacketsSec, `
                        $ServerStatus.AvailableMemory, `
                        $ServerStatus.BytesTotalSec, `
                        $ServerStatus.BytesSentSec, `
                        $ServerStatus.BytesRecvSec
                
                    if ($Env.InfluxDB.Auth -eq $true) {
                        # InfluxDB의 내부 인증을 사용하는 고객사
                        $InfluxdbResult = Invoke-RestMethod -Headers @{Authorization=$authheader} -Uri $InfluxdbURI -Method POST -Body $postParams
                    } else {
                        # InfluxDB의 내부 인증을 사용하지 않는 고객사는 Auth Header를 제거합니다.
                        $InfluxdbResult = Invoke-RestMethod -Uri $InfluxdbURI -Method POST -Body $postParams
                    }
                    
    
                }

                if ($Env.EnableWebHook -eq $true) {
                    # Slack, LINE, JANDI 등의 Chatbot에 Alert을 보냅니다.
                    # 각 Data의 임계치를 정하여 문제가 발생시 또는 주기적으로 발송합니다.

                    # ex) CPU Utilization using slack
                    # 고객사마다 다르지만 40%에서 Alert을 받기를 원하는 고객도 있습니다.
                    # 보통 60% 정도를 Warning 으로 보고 80%를 Critical로 고려하시면됩니다. configruation.json 에 설정합니다.
                    if ($ServerStatus.ProcessorTime -gt $Env.CpuUtilLimit) {
                        SendSlack "#general"  "[Performance-Alert]" "*$ServerName*" "warning" ("CPU Utili is high!! : ("+$ServerStatus.ProcessorTime+"%)")
                    }


                    if ($ServerStatus.GameProcCount -eq 0) {
                        # 모니터링 GameServer Process가 없을경우 2분마다 Alert을 보냅니다. -gt {sec} 에서 운영상에서는 -gt 120 으로 설정하는것을 추천드립니다.
                        if (  (($AlertSendTime -eq $null) -or (((Get-Date)-$AlertSendTime).Second -gt 120 )) ) {
                            if ( $IsAlertSend -eq $false ) {
                                $AlertSendTime = (Get-Date)
                                SendSlack "#general"  "[GameServer-Alert]" $ServerName "danger" ("*"+$ServerStatus.GameProcName+"* stopped on "+$ServerName+" at _$AlertSendTime`_.")
                                $IsAlertSend = $true
                            }
                        } Else {
                            $IsAlertSend = $false
                        }
                    } ElseIf ($isAlertSend -eq $true) {
                        SendSlack "#general"  "[GameServer-Alert]" $ServerName "good" ("*$ServerName* started at _$AlertSendTime`_.")
                        $isAlertSend = $false
                    }
                }
                
                # 프로세스가 좀비상태에 빠졌을 때
                # search the process parent
                $GameProcId = (Get-Process | ? {$_.Name -eq $GameProcName}).Id
                $parentGameProcess = (gwmi win32_process | ? processid -eq  $GameProcId).parentprocessid
	        if (($parentGameProcess -eq $null ) 
                    SendSlack "#general"  "[GameServer-Alert]" $ServerName "danger" ("*"+$ServerStatus.GameProcName+"* zombied on "+$ServerName+" at _$AlertSendTime`_.")              
                }

                # CheckInterval 간격으로 실행합니다.
                Start-Sleep -Seconds $Env.CheckInterval

            } -ArgumentList $ServerName

        } ElseIf ($ServerName.ToLower() -imatch "lin") {

            # Linux 모니터링
            #$o = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck

            #Invoke-Command -ComputerName $ServerName -Authentication Basic -SessionOption $o -Credential $oscred -ScriptBlock { Get-Process }
        }        

    } -ArgumentList $Servername

}

<#Servername.txt
Linux-01
Linux-02
Windows-01
Windows-02
#>
