@echo off
setlocal enabledelayedexpansion
echo ###############################################################################
echo rmccurdyDOTcom
echo This script will download and install a buncha stuff I use for base Windows builds
echo ###############################################################################

SET DIR=%~dp0%

CHOICE /C YN /N /T 5 /D N /M "Install Cygwin and optional Windows apps ? Y/N"
IF ERRORLEVEL 1 SET CYGWIN=YES
IF ERRORLEVEL 2 SET CYGWIN=NO
 
 
CHOICE /C YN /N /T 5 /D N /M "Run Debloat? Y/N"
IF ERRORLEVEL 1 SET DEBLOAT=YES
IF ERRORLEVEL 2 SET DEBLOAT=NO
 
SET ERRORLEVEL=0

IF "%DEBLOAT%" == "YES" (
CALL :DEBLOAT
) 

IF "%CYGWIN%" == "YES" (
CALL :CYGWIN
)

echo [+] Checking powershell version...
@powershell if ($PSVersionTable.PSVersion.Major -eq 5) {    Write-Host " [+] You are running PowerShell version 5"}else {    Write-Host " [+] This is version $PSVersionTable.PSVersion.Major Please update!!!";Start-Sleep -s 99 }


echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

goto main1


CALL :theEnd


:DEBLOAT
echo [+] Downloading/Installing Win10Hardening_Debloat.ps1
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/freeload101/SCRIPTS/raw/master/Windows_Powershell_ps/Win10Hardening_Debloat.ps1','%DIR%Win10Hardening_Debloat.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%Win10Hardening_Debloat.ps1' %*"
EXIT /B %ERRORLEVEL%

:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit
:theEnd


:main1
echo [+] Disabling PowerShell Executionpolicy
@powershell.exe   -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA==

echo [+] Downloading/Installing chocolatey

::choco upgrade chocolatey
choco upgrade chocolatey -y

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"

set PATH=%PATH%;"C:\ProgramData\chocolatey\bin"
choco feature enable -n allowGlobalConfirmation

:: Licensed Chocolatey Pro 
mkdir "C:\ProgramData\chocolatey\license"
copy /y "%DIR%chocolatey.license.xml" "C:\ProgramData\chocolatey\license\chocolatey.license.xml"
 
choco upgrade chocolatey.extension

echo [+] Running Sync Check ?
choco list -lo

echo [+] Installing Packages
choco upgrade "chromium" "irfanview" "irfanview-shellextension" "irfanviewplugins" "vlc" "7zip" "Mobaxterm" "notepadplusplus" "filezilla" 

echo [+] Upgrading all Packages
choco upgrade all -y

:: dirty hack to make updates autorun on boot Choco has AU script but its stupid comlicated (AU)
sc delete "Chocolatey_Update"
sc create "Chocolatey_Update"  binpath= "cmd /c start powershell.exe -nop -w hidden -c \"choco upgrade chocolatey -y\""
sc description Chocolatey_Update "Chocolatey_Update"
sc config Chocolatey_Update start= auto
net start Chocolatey_Update
EXIT /B %ERRORLEVEL%

:CYGWIN

echo [+] Installing additional choco apps 
choco upgrade "openshot" "plexamp" "veracrypt" "libreoffice-fresh" 

::cygwinportable
echo [+] Downloading/Installing Cygwin Portable
echo [+] Exit now if you do not want to install Cygwin
timeout /t 10
cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/vegardit/cygwin-portable-installer/raw/main/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg','%DIR%\cygwin\bin\apt-cyg'))"
EXIT /B %ERRORLEVEL%

:theEnd

echo [+] All done!
pause
exit
