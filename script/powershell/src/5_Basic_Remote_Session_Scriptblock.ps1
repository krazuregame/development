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
$UserName = '**********'
$UserPW = '**********'
$ServerListPath = '~\Servername.txt'

# Ignore all error due to excute PowerSehll command
$ErrorActionPreference = "SilentlyContinue"

$SecureUserPw = $UserPw | ConvertTo-SecureString -AsPlainText -Force
$OsCred = New-Object pscredential ($UserName, $SecureUserPw)

$ServerList = Get-Content -Path $ServerListPath

Foreach ($ServerName in $ServerList) {

    # Terminal이 종료되어도 실행을 보장하기 위하여 Background로 실행합니다.
    Start-Job -Name $ServerName -ScriptBlock { 
        param([string]$ServerName, [string]$OsCred)

        # need to export environment config (JSON)
        $StoredRawData = $true
        $EnableWebHook = $true
        $CheckInterval = 5
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
                    $GameProcName = "win32calc"
                    $GameProcCount = (Get-Process | ? {$_.Name -eq $GameServerName}).count

                    $Counters = @(
                        '\processor(_total)\% processor time',
                        '\System\Processor Queue Length',
                        '\Memory\Pages/sec',
                        '\Paging File(_total)\% Usage',
                        '\Memory\Available MBytes',
                        '\Network Adapter()\Packets/sec',
                        '\Network Adapter()\Bytes Total/sec'
                    )

                    # 부하를 줄이기 위하여 한번에 Query합니다.
                    $status = Get-Counter -Counter $Counters

                    New-Object -TypeName PSCustomObject -Property @{
                        GameProcName   =$GameServerName
                        GameProcCount  =$GameServerCount
                        ProcessTime    =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "processor time"}).CookedValue); 
                        ProcessQueue   =[int]($status.CounterSamples.Where({$_.Path -match "Processor Queue Length"}).CookedValue);
                        PagesSec       =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Pages/sec"}).CookedValue);
                        PagingUsage    =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Paging File(_total)\% Usage"}).CookedValue);
                        AvailableMemory=[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Available MBytes"}).CookedValue);                        
                        PacketsSec     =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Packets/sec"}).CookedValue);
                        BytesTotalSec  =[decimal]("{0:n2}" -f $status.CounterSamples.Where({$_.Path -match "Bytes Total/sec"}).CookedValue / 1MB);
                    }
                } # }}} ScriptBlock                 
                

                if ($StoredRawData -eq "$true") {
                    # Sleep 시간단위로 Database에 누적 저장합니다.
                    # SQL Server, InfluxDB, ElasticSearch, MongoDB 등
                }

                if ($EnableWebHook -eq "$true") {
                    # Slack, LINE, JANDI 등의 Chatbot에 Alert을 보냅니다.
                    # 각 Data의 임계치를 정하여 문제가 발생시 또는 주기적으로 발송합니다.

                    # ex) CPU Utilization using slack
                    if ($ServerStatus.ProcessTime -gt 1) {
                        SendSlack "#general"  "[Performance-Alert]" "*$ServerName*" "warning" ("CPU Utili is high!! : ("+$ServerStatus.ProcessTime+"%)")
                    }


                    if ($ServerStatus.GameProcCount -eq 0) {
                        # 모니터링 GameServer Process가 없을경우 2분마다 Alert을 보냅니다.
                        if (  (($AlertSendTime -eq "$null") -or (((Get-Date)-$AlertSendTime).Second -gt 10 )) ) {
                            if ( $IsAlertSend -eq "$false" ) {
                                $AlertSendTime = (Get-Date)
                                SendSlack "#general"  "[GameServer-Alert]" $ServerName "danger" ("*"+$ServerStatus.GameProcName+"* stopped on "+$ServerName+" at _$AlertSendTime`_.")
                                $IsAlertSend = $true
                            }
                        } Else {
                            $IsAlertSend = $false
                        }
                    } ElseIf ($isAlertSend -eq "$true") {
                        SendSlack "#general"  "[GameServer-Alert]" $ServerName "good" ("*$ServerName* started at _$AlertSendTime`_.")
                        $isAlertSend = $false
                    }
                }

                # CheckInterval 간격으로 실행합니다.
                Start-Sleep -Seconds $CheckInterval

            } -ArgumentList $ServerName

        } ElseIf ($ServerName.ToLower() -imatch "lin") {

            # Linux 모니터링
            #$o = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck

            #Invoke-Command -ComputerName $ServerName -Authentication Basic -SessionOption $o -Credential $oscred -ScriptBlock { Get-Process }
        }        

    } -ArgumentList $Servername, $oscred

}

<#Servername.txt
Linux-01
Linux-02
Windows-01
Windows-02
#>
