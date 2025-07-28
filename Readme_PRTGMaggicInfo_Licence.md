# PRTG-MagicInfo-Licence.ps1
This script check MagicInfo Server Licence Status

## Install
Download Script [PRTG-MagicInfo-Licence.ps1](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/224402d0a05a794a652164a053ae9090d66cb84c/PRTG-MagicInfo-Licence.ps1)
and place it on your PRTG probe under
'C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML'

## Script Usage
1. In PRTG, add an **EXE/Script Advanced Sensor** to your probe.
2. Name the sensor, e.g., *Magic Info Server Licence Informations*.
3. In the **EXE/Script** dropdown, select the script.
4. Set the following parameters:

| Parameter   | Example                                | Description                                      |
|-------------|----------------------------------------|--------------------------------------------------|
| Server     | `https://yourmagicinfoserver:7001`      | URL of your Magic Info Server      |
| username    | `MagicInfoUser with API Rgihts` | you can put user directly or use PRTG variable likke %linuxuser                        |
| password   | `Your Password to the MagicInfoUser`    | you can put password in cleartext or better use PRTG Variable like %linuxpassword    |

Parameter Example:

> -Server "http://mymagicinfoserver.test.com:7001" -username "%linuxuser" -password "%linuxpassword"

Set preferred interval. Recommendation is 12 - 24 hours (once a day)

## Example Scrreenshot
<img width="1438" height="660" alt="image" src="https://github.com/user-attachments/assets/79028798-0866-49b7-a02a-f596e319d9c0" />

