# PRTG-MagicInfo-CountDeviceConnections.ps1
This script connect to MagicInfo Server and search for the defined Device by the IP and return informations from the Server about the Device

## Install
Download Script [MagicInfo_DeviceSensor.ps1](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/main/MagicInfo_DeviceSensor.ps1)
and place it on your PRTG probe under
'C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML'

## Script Usage
1. In PRTG, add an **EXE/Script Advanced Sensor** to your probe.
2. Name the sensor, e.g., *Magic Info Device Sensor*.
3. In the **EXE/Script** dropdown, select the script.
4. Set the following parameters:

| Parameter   | Example                                | Description                                      |
|-------------|----------------------------------------|--------------------------------------------------|
| Server     | `https://yourmagicinfoserver:7001`      | URL of your Magic Info Server      |
| username    | `MagicInfoUser with API Rgihts` | you can put user directly or use PRTG variable likke %linuxuser                        |
| password   | `Your Password to the MagicInfoUser`    | you can put password in cleartext or better use PRTG Variable like %linuxpassword    |
| DeviceIP | 192.0.0.1 | You can also use the PRTG %host variable if you directly want to monitor a device |
| PageSize | 500 | Count of device to be queried at once - should be higher than amount of devices. The script will avoid paginations error by grouping the pages |

Parameter Example:

> -Server "http://mymagicinfoserver.test.com:7001" -username "%linuxuser" -password "%linuxpassword" -PageSize 500 -DeviceIP %host

- Set preferred interval. Recommendation is above 10min - depending on amount of devices on MagicInfo Installation. If it is to low, RestAPI and MagicInfo Webservice will fail after some time.
- Primary channel is "Power Status"

## Example Scrreenshot
<img width="1439" height="910" alt="image" src="https://github.com/user-attachments/assets/75f681b4-fdfb-4a92-be9c-b37ac912df31" />

### Note 
The Script search the device ID inside MagicInfo by the IP Adress and then connect to 2 different rest API URLs to get datas.
The wanted fields can be extended when wished - just let me know

Here the both used API URLs:
- /restapi/v2.0/rms/devices - Get all device information.
- /restapi/v2.0/rms/devices/{deviceId} - Get specific device information
