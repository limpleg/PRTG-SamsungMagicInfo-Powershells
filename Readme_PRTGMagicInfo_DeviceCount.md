# PRTG-MagicInfo-CountDeviceConnections.ps1
This script count Devices connected/disconnected to the MagicInfo Server

## Install
Download Script [PRTG-MagicInfo-CountDeviceConnections.ps1](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/main/PRTG-MagicInfo-CountDeviceConnections.ps1)
and place it on your PRTG probe under
'C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML'

## Script Usage
1. In PRTG, add an **EXE/Script Advanced Sensor** to your probe.
2. Name the sensor, e.g., *Magic Info Server Device Count*.
3. In the **EXE/Script** dropdown, select the script.
4. Set the following parameters:

| Parameter   | Example                                | Description                                      |
|-------------|----------------------------------------|--------------------------------------------------|
| Server     | `https://yourmagicinfoserver:7001`      | URL of your Magic Info Server      |
| username    | `MagicInfoUser with API Rgihts` | you can put user directly or use PRTG variable likke %linuxuser                        |
| password   | `Your Password to the MagicInfoUser`    | you can put password in cleartext or better use PRTG Variable like %linuxpassword    |

Parameter Example:

> -Server "http://mymagicinfoserver.test.com:7001" -username "%linuxuser" -password "%linuxpassword"

- Set preferred interval. Recommendation is 10min
- Set alerts as you wish on disconnected devices

## Example Scrreenshot
<img width="1427" height="557" alt="image" src="https://github.com/user-attachments/assets/70522fa1-8736-4f3b-b480-c94a1b1af1c9" />
