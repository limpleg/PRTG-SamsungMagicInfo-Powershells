# Set PRTG Parameters
param (
    [string]$Server = $(throw "<prtg><error>1</error><text>-Server parameter is missing</text></prtg>"),
    [string]$username = $(throw "<prtg><error>1</error><text>-Username parameter is missing</text></prtg>"),
    [string]$password = $(throw "<prtg><error>1</error><text>-Password parameter is missing</text></prtg>")
)

# MagicInfo RestAPI URLs
$authUrl = "$Server/MagicInfo/restapi/v2.0/auth"
$devicesUrl = "$Server/MagicInfo/restapi/v2.0/rms/devices?pageSize=500&startIndex=1"
$connectionsCheckedUrl = "$Server/MagicInfo/restapi/v2.0/rms/devices/connections-checked"

# UNIX TIMESTAMP (milliseconds since 1970)
$epoch = Get-Date -Date "1970-01-01T00:00:00Z"
$now = Get-Date
$timeMillis = [math]::Round($now.ToUniversalTime().Subtract($epoch).TotalMilliseconds)

# Authentication body
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

# Login and retrieve API key
try {
    $loginResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Body $authBody -ContentType "application/json"
    $apiKey = $loginResponse.token
} catch {
    Write-Output "<prtg><error>1</error><text>❌ Login failed: $($_.Exception.Message)</text></prtg>"
    exit
}

# Header with API key
$headers = @{
    "api_key" = $apiKey
    "Accept"  = "application/json"
    "Content-Type" = "application/json"
}

# Fetch devices and extract IDs
try {
    $response = Invoke-RestMethod -Uri $devicesUrl -Method Get -Headers $headers
    $deviceIds = @()
    foreach ($device in $response.items) {
        if ($device.deviceId) {
            $deviceIds += $device.deviceId
        }
    }
} catch {
    Write-Output "<prtg><error>1</error><text>❌ Failed to retrieve device information: $($_.Exception.Message)</text></prtg>"
    if ($_.Exception.Response -ne $null) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
    Write-Output  "<prtg><error>1</error><text>Response content:`n$responseBody</text></prtg>"
    }
    exit
}

# Split IDs into chunks
$chunkSize = 1
$chunks = [System.Collections.Generic.List[object]]::new()
for ($i = 0; $i -lt $deviceIds.Count; $i += $chunkSize) {
    $chunks.Add($deviceIds[$i..([Math]::Min($i + $chunkSize - 1, $deviceIds.Count - 1))])
}

# Initialize counters
$successCount = 0
$failCount = 0
$failedDevices = @()

# Check each chunk
foreach ($chunk in $chunks) {
    $body = @{ ids = $chunk } | ConvertTo-Json -Depth 2
    try {
        $response = Invoke-RestMethod -Uri $connectionsCheckedUrl -Method Post -Headers $headers -Body $body
        $successCount += $response.items.successList.Count
        $failCount += $response.items.failList.Count
        $failedDevices += $response.items.failList
    } catch {
        if ($_.Exception.Response -ne $null) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $responseBody = $reader.ReadToEnd()
                $parsedResponse = $responseBody | ConvertFrom-Json
                $successCount += $parsedResponse.items.successList.Count
                $failCount += $parsedResponse.items.failList.Count
                $failedDevices += $parsedResponse.items.failList
            } catch {
    Write-Output  "<prtg><error>1</error><text>❌ Failed to parse response as JSON.</text></prtg"
            }
        }
    }
}

# PRTG-compatible XML output
[xml]$prtgOutput = @"
<prtg>
    <result>
        <channel>Connected Devices</channel>
        <value>$successCount</value>
    </result>
    <result>
        <channel>Disconnected Devices</channel>
        <value>$failCount</value>
    </result>
    <text>Connection check completed: $successCount successful, $failCount failed.</text>
</prtg>
"@

$prtgOutput.OuterXml
