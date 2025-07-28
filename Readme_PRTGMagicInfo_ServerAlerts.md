# MagicInfo_ServerAlerts.ps1
This script check MagicInfo Server for alerts and and if alert available it puts the state to error with error in the PRTG Sensor header

## Install
Download Script [MagicInfo_ServerAlerts.ps1](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/e2afcc646ca25130964ae8b433166ddd797dff79/MagicInfo_ServerAlerts.ps1)
and place it on your PRTG probe under
'C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML'

## Script Usage
1. In PRTG, add an **EXE/Script Advanced Sensor** to your probe.
2. Name the sensor, e.g., *Magic Info Server Alerts*.
3. In the **EXE/Script** dropdown, select the script.
4. Set the following parameters:

| Parameter   | Example                                | Description                                      |
|-------------|----------------------------------------|--------------------------------------------------|
| Server     | `https://yourmagicinfoserver:7001`      | URL of your Magic Info Server      |
| username    | `MagicInfoUser with API Rgihts` | you can put user directly or use PRTG variable likke %linuxuser                        |
| password   | `Your Password to the MagicInfoUser`    | you can put password in cleartext or better use PRTG Variable like %linuxpassword    |

Parameter Example:

> -Server "http://mymagicinfoserver.test.com:7001" -username "%linuxuser" -password "%linuxpassword"

Set preferred interval. Recommendation is 1 hour

## Example Scrreenshot
<img width="1442" height="511" alt="image" src="https://github.com/user-attachments/assets/6b6d3e63-0975-4da4-888f-4f4c2f888215" />

