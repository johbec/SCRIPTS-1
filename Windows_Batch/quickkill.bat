@echo off 
:: If you don't have localadmin... powershell.exe -exec bypass -enc UwBlAHQALQBWAGEAcgBpAGEAYgBsAGUAIAAtAE4AYQBtAGUAIABFAHIAcgBvAHIAQQBjAHQAaQBvAG4AUAByAGUAZgBlAHIAZQBuAGMAZQAgAC0AVgBhAGwAdQBlACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQANAAoAZwBlAHQALQBwAHIAbwBjAGUAcwBzAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsAIAAkAF8ALgBQAHIAbwBjAGUAcwBzAE4AYQBtAGUAIAAgAC0AbgBvAHQAbQBhAHQAYwBoACAAJwBTAGUAYwB1AHIAaQB0AHkASABlAGEAbAB0AGgASABvAHMAdAB8AEMAUwBGAGEAbABjAG8AbgBDAG8AbgB0AGEAaQBuAGUAcgB8AEMAUwBGAGEAbABjAG8AbgBTAGUAcgB2AGkAYwBlAHwAUwBlAGMAdQByAGkAdAB5AEgAZQBhAGwAdABoAFMAZQByAHYAaQBjAGUAfABTAGUAYwB1AHIAaQB0AHkASABlAGEAbAB0AGgAUwB5AHMAdAByAGEAeQB8AGMAbQBkAHwAZQB4AHAAbABvAHIAZQByAHwAdABhAHMAawBtAGcAcgB8AHMAdgBjAGgAbwBzAHQAfABjAG8AbgBoAG8AcwB0AHwAZgBpAG4AZAB8AGwAcwBhAHMAcwB8AGQAdwBtAHwAcwBpAGgAbwBzAHQAfABmAG8AbgB0AGQAcgB2AGgAbwBzAHQAfABjAHQAZgBtAG8AbgB8AHQAYQBzAGsAbABpAHMAdAB8AGQAbABsAGgAbwBzAHQAfABsAHMAYQBpAHMAbwB8AHAAdwBzAGgAfABwAG8AdwBlAHIAcwBoAGUAbABsAF8AaQBzAGUAfABwAG8AdwBlAHIAcwBoAGUAbABsACcAIAB9ACAAIAB8AFMAbwByAHQALQBPAGIAagBlAGMAdAAgAC0AVQBuAGkAcQB1AGUAIAAtAFAAcgBvAHAAZQByAHQAeQAgACQAXwAuAFAAcgBvAGMAZQBzAHMATgBhAG0AZQAgACAAfAAgAGYAbwByAGUAYQBjAGgALQBvAGIAagBlAGMAdAAgAHsAUwB0AG8AcAAtAHAAcgBvAGMAZQBzAHMAIAAtAG4AYQBtAGUAIAAkAF8ALgBQAHIAbwBjAGUAcwBzAE4AYQBtAGUAIAAtAEYAbwByAGMAZQB9ACAA
taskkill /F /IM chrome.exe
reg delete HKLM\SOFTWARE\Policies\Google  /f
 

net stop audiosrv /Y
net start audiosrv

echo Run this as administrator! WARNING: This program violently  kills all tasks not in the Exclusions= you may need to add others tested Windows 10
echo 06/29/2021: added CS and Windows Defender to whitelist and task kill as normal admin and trusted installer also wipes chrome policies
echo 06/28/2020: added lsaiso.exe to whitelist for windows 10
echo 11/8/2018: added TrustedInstaller hack to taskkill
echo RMcCurdy.com
echo ==========================================================================
 
CD /D "%~DP0"
SET Exclusions=SecurityHealthHost.exe CSFalconContainer.exe CSFalconService.exe SecurityHealthService.exe SecurityHealthSystray.exe cmd.exe explorer.exe taskmgr.exe svchost.exe conhost.exe find.exe lsass.exe dwm.exe  sihost.exe fontdrvhost.exe ctfmon.exe  tasklist.exe dllhost.exe lsaiso.exe pwsh.exe powershell_ise.exe powershell.exe

SET tmpfl=%~n0tmp.dat
IF EXIST "%tmpfl%" DEL /F /Q "%tmpfl%"
IF EXIST "output.log" DEL /F /Q "output.log"
SET Exclusions=%Exclusions% taskkill.exe tasklist.exe

SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "DELIMS=: TOKENS=2" %%A IN ('TASKLIST    /FO LIST ^| FIND /I "Image name:"') DO (
    SET var=%%~A
    SET var=!var: =!
    ECHO !var! | FINDSTR /I /V "%Exclusions%">>"%tmpfl%"
)
FOR /F "USEBACKQ TOKENS=*" %%A IN ("%tmpfl%") DO (
sc stop "TrustedInstaller"    1>> output.log 2>&1

sc config TrustedInstaller binPath= "cmd /c TASKKILL /F  /IM %%~A"    1>> output.log 2>&1

echo killing %%~A  1>> output.log 2>&1

echo killing %%~A  as Trustedinstaller 
sc start "TrustedInstaller"   1>> output.log 2>&1

echo killing %%~A  as Current Use: "%USERNAME%"
TASKKILL /F  /IM %%~A 1>> output.log 2>&1


REM dont remove this or things will go wrong...it will fix the service back
sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"   1>> output.log 2>&1
sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"  1>> output.log 2>&1

)
DEL /F /Q "%tmpfl%"
echo All clean!
 
CHOICE /T 1 /C y /CS /D y > %temp%/null
:: removed to support Bleachbit/quickkill   taskkill /F /IM cmd.exe
exit
