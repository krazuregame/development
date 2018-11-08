

```powershell
# EA Enroll Number
$enrollmentNo = "********"

# EA Portal Access Key
$accesskey = "****************" 
$authHeaders = @{"authorization"="bearer $accesskey"} 

# Current Month
$date = get-date
$period= $date.ToString("yyyyMM")

# Credit Start Month
$startperiod = "201810"

$totalUrl = "https://consumption.azure.com/v2/enrollments/$enrollmentNo/billingperiods/$startperiod/balancesummary"
$total = Invoke-WebRequest $totalUrl -Headers $authHeaders -UseBasicParsing
$total = $total.Content | ConvertFrom-Json 

$summaryUrl = "https://consumption.azure.com/v2/enrollments/$enrollmentNo/billingperiods/$period/balancesummary"
$summary = Invoke-WebRequest $summaryUrl -Headers $authHeaders -UseBasicParsing 
$summary = $summary.Content | ConvertFrom-Json 

<#
# 크레딧 Total 금액
$total.adjustments

# 해당 월 Credit 시작 금액
$date.ToString("yyyy-MM-dd")
$summary.beginningBalance

# 해당 월 Credit 잔액 금액
$summary.endingBalance

# 해당 월 Credit 사용 금액 
$summary.utilized

# 총 사용금액
#>


$a = $date.ToString("yyyy-MM-dd")
$b = $total.adjustments.ToString('N0')
$c = $summary.endingBalance.ToString('N0')
$d = $summary.utilized.ToString('N0')
$e = ($b-$c).ToString('N0')

$row ="
    </tr>
    <th> $a</th>
    <th> $b Won</th>
    <th> $c Won</th>
    <th> $d Won</th>
    <th> $e Won</th>
    </tr>
    "

$report = "<html>
<style>
{font-family: Arial; font-size: 15pt;}
TABLE{border: 1px solid black; border-collapse: collapse; font-size: 13pt;}
TH{border: 1px solid black; background: #ffffff; padding: 5px; color: #000000;}
TD{border: 1px solid black; padding: 5px; }
</style>
<h2>[NPixel] Azure Credit - Daily Report</h2>
<table>
<tr>
<th>Date</th>
<th>Total Amount</th>
<th>Current Balance</th>
<th>Monthly Usage</th>
<th>Total Usage</th>
</tr>
$row
</table>
<tr>
<br />For more information, please check the EA Portal below.
<br /><a href='https://ea.azure.com' target='_blank'> https://ea.azure.com </a>
<br /><br />Sent at $date
"


#$report | add-Content "~\DailyReport-$today.html" 
#https://docs.microsoft.com/ko-kr/azure/sendgrid-dotnet-how-to-send-email

# SendGrid Username
$Username ="***********@azure.com"
# SendGrid Password
$Password = ConvertTo-SecureString "*********" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $Username, $Password

$SMTPServer = "smtp.sendgrid.net"
$EmailFrom = "No-reply@npixel.com"

[string[]]$EmailTo = "*****@npixel.co.kr", "molee@microsoft.com", …

$Subject = "Azure Credit Daily Report"
$Body = $report

Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -Port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body $Body -BodyAsHtml


```

