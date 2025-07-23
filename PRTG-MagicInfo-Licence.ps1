# Set PRTG Parameters
 
 param (
    [string]$Server = $(throw "<prtg><error>1</error><text>-Server is missing in parameters</text></prtg>"),
    [string]$username = $(throw "<prtg><error>1</error><text>-Username is missing in parameters</text></prtg>"),
    [string]$password = $(throw "<prtg><error>1</error><text>-Password is missing in parameters</text></prtg>")
)


# === MagicInfo RestAPI URLs ===
$authUrl = "$server/MagicInfo/restapi/v2.0/auth"
$licenseUrl = "$server/MagicInfo/restapi/v2.0/ems/settings/licenses"

# === UNIX TIMESTAMP (Miliseconds since 1970) ===
$epoch = Get-Date -Date "1970-01-01T00:00:00Z"
$now = Get-Date
$timeMillis = [math]::Round($now.ToUniversalTime().Subtract($epoch).TotalMilliseconds)

# === Authentication-BODY ===
$authBody = @{
    grantType = "password"
    username = $username
    password = $password
    hotp = ""
    totp = ""
    refreshToken = ""
    token = ""
    userAuthDevice = @{
        authDeviceId = 0
        authDeviceName = "PowerShellClient"
        authEnable = $true
        browserName = "PowerShell"
        browserVersion = "7.0"
        createDate = $timeMillis
        expiredDate = $timeMillis
        latestDate = $timeMillis
        osName = "Windows"
        osVersion = "10"
        secretKey = ""
        userId = $username
    }
} | ConvertTo-Json -Depth 5

try {
    $loginResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Body $authBody -ContentType "application/json"
    $apiKey = $loginResponse.token

} catch {
    Write-Output "<prtg><error>1</error><text>❌ Login Error: $($_.Exception.Message)</text></prtg>"
    exit
}

# === HEADER with API-KEY ===
$headers = @{
    "api_key" = $apiKey
    "Accept"  = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $licenseUrl -Method Get -Headers $headers
    $license = $response.items[0]


# === Day Calculation ===


function Convert-MillisToDate {
    param ([Nullable[Int64]]$millis)
    if ($null -eq $millis -or $millis -eq 0) {
        return "null"
    }
    try {
        $epoch = Get-Date -Date "1970-01-01T00:00:00Z"
        $date = $epoch.AddMilliseconds([Int64]$millis)
        return $date.ToString("yyyy-MM-dd HH:mm:ss")

    } catch {
        return "invalid"
    }
}

function Days-Since {
    param ([string]$dateString)
    if ([string]::IsNullOrWhiteSpace($dateString)) {
        return -1
    }
    try {
        $parsedDate = [datetime]$dateString  # PowerShell erkennt das Format automatisch
        $now = Get-Date
        return [math]::Round(($now - $parsedDate).TotalDays, 0)
    } catch {
        return -1
    }
}

# $license with milisecond timestamp - convert to date
$startDate     = Convert-MillisToDate $license.startDate
$endDate       = Convert-MillisToDate $license.endDate
$regDate       = Convert-MillisToDate $license.regDate
$maintEndDate  = Convert-MillisToDate $license.maintEndDate

# Calculacion between now and timestamp
$daysSinceStart     = Days-Since $startDate
$daysSinceEnd       = Days-Since $endDate
$daysSinceReg       = Days-Since $regDate
$daysSinceMaintEnd  = Days-Since $maintEndDate

#PRTG Output

$xml = @"
<prtg>

  <result>
    <channel>Max Clients</channel>
    <value>$($license.maxClients)</value>
    <unit>Count</unit>
  </result>
  <result>
    <channel>Days since start of licence</channel>
    <value>$daysSinceStart</value>
    <unit>Custom</unit>
    <CustomUnit>Days</CustomUnit>
  </result>
  <result>
    <channel>Days until end of licence</channel>
    <value>$daysSinceEnd</value>
    <unit>Custom</unit>
    <CustomUnit>Days</CustomUnit>
  </result>
  <result>
    <channel>Days since registration</channel>
    <value>$daysSinceReg</value>
    <unit>Custom</unit>
    <CustomUnit>Days</CustomUnit>
  </result>
  <result>
    <channel>Days since maintenance ended</channel>
    <value>$daysSinceMaintEnd</value>
    <unit>Custom</unit>
    <CustomUnit>Days</CustomUnit>
  </result>
  <text>
    License Key: $($license.licenseKey)
    Product Code: $($license.productCode)
    Product Name: $($license.productName)
    License Type: $($license.licenseType)
  </text>
</prtg>
"@

Write-Output $xml

} catch {
    Write-Output "<prtg><error>1</error><text>❌ Fehler beim Abrufen der Lizenzinformationen: $($_.Exception.Message)</text></prtg>"
    if ($_.Exception.Response -ne $null) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Antwortinhalt:`n$responseBody"
    }
}
