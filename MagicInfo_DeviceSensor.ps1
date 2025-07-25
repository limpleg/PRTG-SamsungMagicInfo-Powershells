# === PRTG Parameters ===
param (
    [string]$Server = $(throw "<prtg><error>1</error><text>❌ Server is missing in parameters</text></prtg>"),
    [string]$username = $(throw "<prtg><error>1</error><text>❌ Username is missing in parameters</text></prtg>"),
    [string]$password = $(throw "<prtg><error>1</error><text>❌ Password is missing in parameters</text></prtg>"),
    [string]$DeviceIP = "0",
    [string]$PageSize = $(throw "<prtg><error>1</error><text>❌ PageSize is missing in parameters</text></prtg>")
)

# === MagicInfo REST API URLs ===
$authUrl = "$Server/MagicInfo/restapi/v2.0/auth"

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

# === Retrieve devices with pagination ===
$allDevices = @()
$startIndex = 1
$pageSize = [int]$PageSize
$hasMore = $true

while ($hasMore) {
    $devicesUrl = "$Server/MagicInfo/restapi/v2.0/rms/devices?pageSize=$pageSize&startIndex=$startIndex"
    try {
        $response = Invoke-RestMethod -Uri $devicesUrl -Method Get -Headers $headers
        if ($response.items) {
            $allDevices += $response.items
            $startIndex += $pageSize
        } else {
            $hasMore = $false
        }
    } catch {
        $errorMsg = $_.Exception.Message
        if ($_.Exception.Response -ne $null) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $errorMsg += " | Response: $responseBody"
        }
        Write-Output "<prtg><error>1</error><text>❌ Error retrieving device information: $errorMsg</text></prtg>"
        exit
    }
}

# === Filter valid devices ===
$validDevices = $allDevices | Where-Object {
    $_.ipAddress -and $_.ipAddress -ne "0.0.0.0"
}

# === Match device by IP ===
$matchingDevices = @()
foreach ($dev in $validDevices) {
    if ($dev.ipAddress.Trim() -eq $DeviceIP.Trim()) {
        $matchingDevices += $dev
    }
}

# === Device matching logic ===
if ($matchingDevices.Count -eq 1) {
    $device = $matchingDevices[0]
    $deviceId = $device.deviceId
} elseif ($matchingDevices.Count -gt 1) {
    $deviceNames = ($matchingDevices | ForEach-Object { $_.deviceName }) -join ", "
    $deviceIDs = ($matchingDevices | ForEach-Object { $_.deviceId }) -join ", "
    Write-Output "<prtg><error>1</error><text>❌ Multiple Device with same IP $DeviceIP found: $deviceNames | IDs: $deviceIDs</text></prtg>"
    exit 1
} elseif ($DeviceIP -eq "0.0.0.0") {
    Write-Output "<prtg><error>1</error><text>❌ Error: The device IP address is '0.0.0.0' – this indicates a faulty or disconnected device.</text></prtg>"
    exit 1
} else {
    $availableIPs = ($validDevices | ForEach-Object { $_.ipAddress }) -join ", "
    Write-Output "<prtg><error>1</error><text>❌ No device found with IP address $DeviceIP. Available IPs: $availableIPs</text></prtg>"
    exit 1
}

# === Retrieve device details ===
$deviceDetailsUrl = "$Server/MagicInfo/restapi/v2.0/rms/devices/$deviceId"

try {
    $deviceDetails = Invoke-RestMethod -Uri $deviceDetailsUrl -Method Get -Headers $headers
} catch {
    $errorMsg = $_.Exception.Message
    if ($_.Exception.Response -ne $null) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        $errorMsg += " | Response: $responseBody"
    }
    Write-Output "<prtg><error>1</error><text>❌ Error retrieving device details: $errorMsg</text></prtg>"
    exit
}

# === XML output for PRTG ===
$device = $deviceDetails.items
$deviceName = $device.deviceName
$deviceType = $device.deviceType
$firmware = $device.firmwareVersion
$powerStatus = if ($device.power) { 1 } else { 0 }
$diskSpace = $device.diskSpaceRepository
$disconnectedDays = ($device.disconnectedTime -split ' ')[0] -as [int]
$ip = $device.ipAddress
$model = $device.deviceModelName
$serial = $device.deviceSerial
$playerVersion = $device.playerVersion
$macAddress = $device.macAddress
$groupNames = ($device.groupPathList | ForEach-Object { $_.groupName }) -join " > "
$ServerInfo = $device.tunnelingServer

$xmlOutput = @"
<prtg>
    <result>
        <channel>Power Status</channel>
        <value>$powerStatus</value>
        <unit>Custom</unit>
        <customunit>Off/On</customunit>
        <limitmode>1</limitmode>
        <limitminerror>1</limitminerror>
        <limitmaxerror>1</limitmaxerror>
    </result>
    <result>
        <channel>Disk Space (Bytes)</channel>
        <value>$diskSpace</value>
        <unit>BytesDisk</unit>
    </result>
    <result>
        <channel>Disconnected Time (Days)</channel>
        <value>$disconnectedDays</value>
        <unit>TimeDays</unit>
    </result>
    <result>
        <channel>Device Model</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$model</customunit>
    </result>
    <result>
        <channel>Firmware Version</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$firmware</customunit>
    </result>
    <result>
        <channel>Player Version</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$playerVersion</customunit>
    </result>
    <result>
        <channel>Serial Number</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$serial</customunit>
    </result>
    <result>
        <channel>Group Path</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$groupNames</customunit>
    </result>
    <result>
        <channel>Group Path</channel>
        <value>1</value>
        <unit>Custom</unit>
        <customunit>$ServerInfo</customunit>
    </result>
    <text>Device: $deviceName | DeviceType: $deviceType | IP: $ip | MacAddress: $macAddress | Firmware: $firmware | Group: $groupNames</text>
</prtg>
"@

# Output for PRTG
Write-Output $xmlOutput
