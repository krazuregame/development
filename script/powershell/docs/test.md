

```powershell

$enrollmentNo = "50188719"
$date = get-date
$period= $date.ToString("yyyyMM")
$startperiod = "201810"
$accesskey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImpoeXA2UU9DWlZmY1pmdmhDVGR1OFdxeTJ5byJ9.eyJFbnJvbGxtZW50TnVtYmVyIjoiNTAxODg3MTkiLCJJZCI6IjI0Mzk3NzEzLWFlZjYtNDEwMS05YTgwLWYyMjk3MjFkMThjNiIsIlJlcG9ydFZpZXciOiJJbmRpcmVjdEVudGVycHJpc2UiLCJQYXJ0bmVySWQiOiIiLCJEZXBhcnRtZW50SWQiOiIiLCJBY2NvdW50SWQiOiIiLCJpc3MiOiJlYS5taWNyb3NvZnRhenVyZS5jb20iLCJhdWQiOiJjbGllbnQuZWEubWljcm9zb2Z0YXp1cmUuY29tIiwiZXhwIjoxNTU2NTMwNjIxLCJuYmYiOjE1NDA4MDU4MjF9.YWJLmj8RuxGWaC0TlhNXdgMiW1cuCrpqh90CyoOXCqwTXGslEiVCYD4rvJho2PYPnVXwBW1z-h5xWdKuyQdbDIj1Vb2K-nGEAKkrcAhwhLKporxevudbL7USo_pJ3Aa_0Gz-55UPivkODr-rViDEIuAgQPipQAJ0ObJXrLt7gAMIk8FCRWigZo7CScI98cYnTuhpILTwKsmipp1FqiKfvczo1glydu8HLhmj7UDB-TMxqt6slaVUHCxGOxLKoEkV9Iz8S6I6YyMnv8BD2X2Q8c5XlSsbfU1_bHQ4DufLhmtiv_HdYzCWw7bHXVgGg1nJvy2g8yAQ9T8pTHMUeXFB9w" 
$authHeaders = @{"authorization"="bearer $accesskey"} 


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

