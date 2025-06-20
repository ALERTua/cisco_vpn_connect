[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://stand-with-ukraine.pp.ua)
[![Made in Ukraine](https://img.shields.io/badge/made_in-Ukraine-ffd700.svg?labelColor=0057b7)](https://stand-with-ukraine.pp.ua)
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)
[![Russian Warship Go Fuck Yourself](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/RussianWarship.svg)](https://stand-with-ukraine.pp.ua)

Cisco Anyconnect Command Line VPN Connection Script
---------------------

Connect to Cisco AnyConnect VPN using the command line. Useful if placed in the Windows Startup folder.

### Usage
I. Create a new generic credential in Windows Credentials Manager
  1. Start Menu
  2. Credentials Manager
  3. Windows Credentials
  4. Generic Credentials
  5. Add a generic credential
  6. Credentials "Internet or network address": Any string, it will be used as Credentials Alias
  7. Username: VPN Username
  8. Password: VPN Password
  9. Save
  10. Don't forget to update the credentials record when you change your password. 

II. Use the script to connect to VPN using the credentials alias
```powershell
powershell vpn_connect.ps1 "VPN URL" "Credentials Alias"
```
III. To get the connection status you can execute `vpn_status.cmd`
IV. To disconnect you can execute `vpn_disconnect.cmd`

### Caveats
- The script outputs your **PLAIN TEXT PASSWORD** to the console once.
- The connection is persistent, but the tray icon is not shown as in the GUI version. 
- If you are disconnected for any reason, you'll still get the GUI dialog about the connection being lost.

Написав ChatGPT. Я лише переклав на рідну мову.
