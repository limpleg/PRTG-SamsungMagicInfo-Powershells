# === PRTG Parameters ===
param (
    [string]$Server = $(throw "<prtg><error>1</error><text>❌ Server is missing in parameters</text></prtg>"),
    [string]$username = $(throw "<prtg><error>1</error><text>❌ Username is missing in parameters</text></prtg>"),
    [string]$password = $(throw "<prtg><error>1</error><text>❌ Password is missing in parameters</text></prtg>")
)

# === MagicInfo REST API URLs ===
$authUrl = "$Server/MagicInfo/restapi/v2.0/auth"
$alertsUrl = "$Server/MagicInfo/restapi/v2.0/sms/system/alerts"

# === UNIX TIMESTAMP (Milliseconds since 1970) ===
$epoch = Get-Date -Date "1970-01-01T00:00:00Z"
$now = Get-Date
$timeMillis = [math]::Round($now.ToUniversalTime().Subtract($epoch).TotalMilliseconds)

# === Authentication Body ===
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

# === Login and retrieve API key ===
try {
    $loginResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Body $authBody -ContentType "application/json"
    $apiKey = $loginResponse.token
} catch {
    Write-Output "<prtg><error>1</error><text>❌ Login error: $($_.Exception.Message)</text></prtg>"
    exit
}

# === Header with API key ===
$headers = @{
    "api_key" = $apiKey
    "Accept"  = "application/json"
}

# === Get Alerts ===
try {
    $alertsResponse = Invoke-RestMethod -Uri $alertsUrl -Method Get -Headers $headers
} catch {
    Write-Output "<prtg><error>1</error><text>❌ Alerts fetch error: $($_.Exception.Message)</text></prtg>"
    exit
}

# === Output for PRTG XML ===
Write-Output "<prtg>"

if ($alertsResponse -and $alertsResponse.Count -gt 0) {
    foreach ($alert in $alertsResponse) {
        $name = $alert.name
        $level = $alert.level
        $text = $alert.multiLanguage[0].text -replace '[<>&]', ''  # Sanitize for XML

        Write-Output "<result>"
        Write-Output "<channel>$name</channel>"
        Write-Output "<value>1</value>"
        Write-Output "<unit>Custom</unit>"
        Write-Output "<valueLookup>prtg.standardlookups.stateonok</valueLookup>"
        Write-Output "<text>[$level] $text</text>"
        Write-Output "</result>"
    }
} else {
    Write-Output "<result><channel>Alerts</channel><value>0</value><text>✅ Keine aktiven Alerts</text></result>"
}

Write-Output "</prtg>"
