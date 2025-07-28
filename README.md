# PRTG-SamsungMagicInfo-Powershells
Several Powershells for Monitoring Samsung MagicInfo Server on PRTG

This scripts connect to the Magic Info Server by Rest API and get informations directly from the server.
Documentation of Rest API found under
> https://YOURMAGICINFOSERVER:7001/MagicInfo/swagger-ui.html

**MagicInfo Version used: 8**

## Basic Install
Download the scripts you want and place it on your PRTG probe under:  
`C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML`

## Features
Click on the links for documentation:

[PRTG MagicInfo Server Alerts](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/main/Readme_PRTGMagicInfo_ServerAlerts.md)
- Monitor Alerts from the MagicInfo Server

[PRTG MagicInfo Licence Informations](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/53fe0817203b3d1edcdc1c12d650aa8aba61c8dd/Readme_PRTGMaggicInfo_Licence.md)
- Monitors the Licence informations and dates of install and maintenance end of the Licence

[PRTG MagicInfo Count Device Connections](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/main/Readme_PRTGMagicInfo_DeviceCount.md)
- Montiors the amount of connected and disconnected devices

[PRTG MagicInfo DeviceSensor](https://github.com/limpleg/PRTG-SamsungMagicInfo-Powershells/blob/main/Readme_PRTGMagicInfo_DeviceSensor.md)

Get informations from the Server about a Device. 
- Device Model
- Dissconnecte Time (Days)
- Disk Space
- Firmware Version
- Group Path
- Monitor Temperature
- Mute On/Off
- Volume
- Player Version
- Power Status
- Serial Number
- Touch Control Lock
- Web Browser URL
