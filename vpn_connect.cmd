
@echo off
powershell "%~dp0\vpn_connect.ps1" "VPN URL" "Credentials Alias"
timeout /t 30
