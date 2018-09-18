$username = '*******'
$userpw = '********'
$secureuserpw = $userpw | ConvertTo-SecureString -AsPlainText -Force
$oscred = New-Object pscredential ($username, $secureuserpw)

$Serverlist = Get-Content -Path C:\Users\azureadmin\Desktop\Servername.txt
Foreach ($Servername in $Serverlist) {
    Start-Job -Name $ServerName -ScriptBlock { param($ServerName, $oscred)

if($servername -imatch "win")
{
    Invoke-Command –ComputerName $ServerName -Credential $oscred -ScriptBlock { Get-Process }
}

if($servername -imatch "lin")
{
    $o = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck
    Invoke-Command -ComputerName $ServerName -Authentication Basic -SessionOption $o -Credential $oscred -ScriptBlock { Get-Process }
}


    } -ArgumentList $Servername, $oscred

}



<#Servername.txt
Linux-01
Linux-02
Windows-01
Windows-02
#>