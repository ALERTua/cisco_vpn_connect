
@echo off
"%ProgramFiles(x86)%\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" disconnect
exit /b %ERRORLEVEL%
