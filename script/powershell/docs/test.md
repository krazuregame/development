

```powershell




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
#>


$a = $date.ToString("yyyy-MM-dd")
$b = $total.adjustments.ToString('N0')
$c = $summary.endingBalance.ToString('N0')
$d = $summary.utilized.ToString('N0')
$e = ($b-$c).ToString('N0')


$uri = "http://rocket.npixel.co.kr/hooks/Zdx4CCSReKgN23wiw/dtCGozaNPAA4QaCQyiCnhnpcNQCA7BSrkjqmFmsy3nMuKk95"

$payload = @{
    "text" = "Date:$a `n Total Credit:$b `n Current Credit:$c `n Monthly Usage:$d `n Total Usage:$e"
    "channel" = "#fgt_cloudtest"
}
Invoke-WebRequest -uri $uri -body $payload -Method Post -UseBasicParsing

```

