
@echo off
"%ProgramFiles(x86)%\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" status
exit /b %ERRORLEVEL%
